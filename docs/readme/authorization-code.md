Authorization code grant type
=============================

### To request an authorization code

* End point:
`GET` `/authorize`

* Request:

    Parameters:
    ```
    grant_type=authorization_code
    client_id=
    redirect_url=
    ```

* Response:

    <b>On success</b>:
    
    `Code`: 
    
        `302 Found`
    
    `Headers`:
    
        `Location: redirect_url?code=`
     
     `Content`:
     
        `{}`

    <b>On Error</b>:
    
    `Code`: 
    
        `404 Bad Request`
    
     `Content`:
     
        `{ Errors: [] }`
 
 * Sample request:

```
$curl -i http://localhost:3000/authorize? \
    grant_type=authorization_code \
    &client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5 \
    &redirect_url=https%3A%2F%2Ftest.com
```

 * Sample result:
 
 ```
HTTP/1.1 302 Found
Location: https://test.com?code=G_Ds4r17gd23134OniYYiA
```

### To request an access token
* End point:
`GET` `/token`

* Request:

    Headers:
    ```
    Authorization: client-id:base64-encoded-client-secret
    ```
    Parameters:
    ```
    grant_type=authorization_code
    code =
    [refresh = true | false]
    ```

* Response:

    <b>On success</b>:
    
    `Code`: 
    
        `200 Ok`
    
     `Content`:
     
        {
            access_token: 
            expires_in:
            scope: []
            [refresh_token: ]
        }

    <b>On Error</b>:
    
    `Code`: 
    
        `404 Bad Request`
     
     `Content`:
     
        `{ Errors: [] }`

* Sample request:
    ```
    $curl -i -H "Authorization: c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5:c2VjcmV0" \
        http://localhost:3000/token? \
        grant_type=authorization_code \
        &code=G_Ds4r17gd23134OniYYiA
    ```

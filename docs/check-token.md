Check token validity
=======================

* End point:
`GET` `/check`

* Request:
    
    Headers:
    
    ```
     Authorization: Bearer access-token
     ```
    
    Parameters:
    ```
    token=[refresh_token | access_token]
    ```

* Response:

    <b>On success</b>:
    
    `Code`: 
    
        `200 Ok`
    
    `Content`:
          
        {
            active: [true | false]
            expires_in:
            grant_type:
            scope: []
            token_type: [access | refresh]
            client_id:
            username:
        }

    <b>On Error</b>:
    
    `Code`: 
    
        `200 Ok`
     
     `Content`:
     
        `{ active: false }`

* Sample request:
    ```
    $ curl -i -H "Authorization: Bearer access-token" http://localhost:3000/check? \
    token=
    ```

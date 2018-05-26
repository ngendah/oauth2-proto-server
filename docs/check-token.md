Check token validity
=======================

* End point:
`GET` `/check`

* Request:
     
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
            expires_in:
            grant_type:
            scope:[]
            token_type: [access | refresh]
        }

    <b>On Error</b>:
    
    `Code`: 
    
        `404 Bad Request`
     
     `Content`:
     
        `{ Errors: [] }`

* Sample request:
    ```
    $ curl -i http://localhost:3000/check? \
    token=
    ```
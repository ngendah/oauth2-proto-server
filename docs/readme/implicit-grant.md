Implicit grant type
=======================

### To request an access token
* End point:
`GET` `/token`

* Request:

    Parameters:
    ```
    grant_type=implicit
    client_id=
    redirect_url=
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
    $curl -i http://localhost:3000/token? \
    grant_type=implicit \
    &client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5 \
    &redirect_url=https%3A%2F%2Ftest.com
    ```
User credentials grant type
===========================

### To request an access token
* End point:
`GET` `/token`

* Request:

    Parameters:
    ```
    grant_type=user_credentials
    client_id=
    user_uid=
    password=
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
        grant_type=user_credentials \
        &client_id=c2ce91a6-98b6-4d4b-99ad-eeb174c0b6d5 \
        &user_uid=9c965d6d-ec9d-45de-9708-13f3f62d7c4d \
        &password=password
    ```

Revoke an existing token
========================

* End point:
`DELETE` `/token`

* Request:

     Headers:
     ```
     Authorization: Bearer access-token
     ```
     
    Parameters:
    ```
    token=[refresh_token | access_token]
    [refresh = true | false]
    ```
    If the token parameter is an access token, then only that token is revoked.
    However, if its a refresh token, then all related access tokens and itself are revoked.

* Response:

    <b>On success</b>:
    
    `Code`: 
    
        `200 Ok`

    <b>On Error</b>:
    
    `Code`: 
    
        `404 Bad Request`
     
     `Content`:
     
        `{ Errors: [] }`

* Sample request:
    ```
    $ curl -i -X 'PUT' http://localhost:3000/token? \
    token=
    ```
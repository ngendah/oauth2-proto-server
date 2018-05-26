Refresh an access token
=========================
You refresh an access token using a previously issued refresh token.

* End point:
`PUT` `/token`

* Request:

    Parameters:
    ```
    refresh_token=
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
    $ curl -i -X 'PUT' http://localhost:3000/token? \
    refresh=true&refresh_token=
    ```

SELECT *
FROM authorization_codes
WHERE client_id = 'santino_von'
  AND authorization_code = 'f55466e8d8e1db9f8cf112c2de8612b3'
  AND redirect_uri = 'http://www.example.com/callback'
ORDER BY authorization_codes.id ASC
LIMIT 1
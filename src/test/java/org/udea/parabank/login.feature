@appcontact_login
Feature: Login to app contact

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

  Scenario: 1. Login exitoso con credenciales válidas
    Given path '/users/login'
    And request { email: 'tester20250630@test.com', password: 'Pass1234*' }
    When method POST
    Then status 200
    And match response.token == '#string'
    * def authToken = response.token

  Scenario: 2. Token reutilizable en peticiones subsecuentes
    * def login = call read('classpath:appcontact_login.feature@Customer Login only')
    * def token = login.authToken
    * header Authorization = 'Bearer ' + token
    Given path '/contacts'
    When method GET
    Then status 200

  Scenario: 3. Login con credenciales inválidas devuelve mensaje claro
    Given path '/users/login'
    And request { email: 'tester20250630@test.com', password: 'WrongPass123' }
    When method POST
    Then status 401
    And match response.message == 'Incorrect email or password'

  Scenario: 4. Login con email en formato inválido
    Given path '/users/login'
    And request { email: 'invalid-email-format', password: 'Pass1234*' }
    When method POST
    Then status 400



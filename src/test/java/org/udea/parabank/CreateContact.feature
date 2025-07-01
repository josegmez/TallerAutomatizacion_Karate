@appcontact_createcontact
Feature: create contact to app contact

  Background:
    * url baseUrl
    * header Accept = 'application/json'

  Scenario: 1. crear contacto
  # Login
    Given path '/users/login'
    And request
  """
  {
    "email": "tester20250630@test.com",
    "password": "Pass1234*"
  }
  """
    When method POST
    Then status 200
    * def authToken = response.token
    * print 'Login OK. Token: ', authToken

  # Crear contacto
    Given path '/contacts'
    And header Authorization = 'Bearer ' + authToken
    And request { "firstName": "Pruebas", "lastName": "UDEA", "birthdate": "1970-01-01", "email": "jdoe@fake.com", "phone": "8005555555", "street1": "1 Main St.", "street2": "Apartment A", "city": "Anytown", "stateProvince": "KS", "postalCode": "12345", "country": "USA" }
    When method POST
    Then status 201

  Scenario: 2. Validar que contacto fue creado (se encuentra en /contacts)
    # Login
    Given path '/users/login'
    And request { email: 'tester20250630@test.com', password: 'Pass1234*' }
    When method POST
    Then status 200
    * def authToken = response.token

    # Obtener contactos
    Given path '/contacts'
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status 200
    And match each response contains { email: '#string' }

  Scenario: 3. Faltan campos requeridos
    # Login
    Given path '/users/login'
    And request { email: 'tester20250630@test.com', password: 'Pass1234*' }
    When method POST
    Then status 200
    * def authToken = response.token

    # Falta el campo firstName
    Given path '/contacts'
    And header Authorization = 'Bearer ' + authToken
    And request
    """
    {
      "lastName": "UDEA",
      "birthdate": "1970-01-01",
      "email": "missing1@mail.com",
      "phone": "8005555555"
    }
    """
    When method POST
    Then status 400

  Scenario: 4. Email duplicado no permitido
    # Login
    Given path '/users/login'
    And request { email: 'tester20250630@test.com', password: 'Pass1234*' }
    When method POST
    Then status 200
    * def authToken = response.token

    # Crear contacto con email fijo
    Given path '/contacts'
    And header Authorization = 'Bearer ' + authToken
    And request
    """
    {
      "firstName": "Dup",
      "lastName": "Email",
      "birthdate": "1990-01-01",
      "email": "jdoe@fake.com",
      "phone": "1234567890"
    }
    """
    When method POST
    Then status 400
    And match response.message contains 'duplicate'

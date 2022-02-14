@Ignore
Feature: Delete an article

  Background: Define URL
    Given url apiUrl

  Scenario: Delete an article
    Given path 'articles',slugId
    When method Delete
    Then status 204
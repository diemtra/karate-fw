@Ignore
Feature: Delete an article

  Background: Define URL
    Given url apiUrl

  Scenario: Delete a new article
    Given path 'articles',slugId
    When method Delete
    Then status 204
# CollectionTools
CollectionTools - R scripts and apps to bring collections data back into the cabinets

#### About CollectionTools
This repository is a compilation of finalized and in-progress R scripts and apps to be used in every day collections management tasks. This compilation of tools are primarily in the form of shiny apps.

### NEON Taxonomy Lookups
The first two complete CollectionTools apps are the NEON_carabids and NEON_mosquitoes apps.  They are deployed online at shinyapps.io.
Carabids: https://mandrewj.shinyapps.io/neonbet/
Mosquitoes: https://mandrewj.shinyapps.io/neonmos/

To modify, replace the associated csv file with one relevant to your collection holdings. If the column headers change within the csv, they will also need to be changed within the associated app.R file.


### Piodiversity
This app is being developed to run on a raspberry pi connected to a monitor within the collections space. The goal is to have a periodicaly (every 5 minutes for most data, every day for maps) page that shows published data including the most recently digitized specimen.  The app is also being developed such that a QR code or NFC tag can be placed on a cabinet and a visitor and pull up that cabinet's taxon list and a map of all digitized specimens within.

This app does not work yet but certain parts can be adapted to other purposes.  It largely is focused on using the Symbiota portal API.


#### Using NFC tags
NFC (near-field communication) tags are similar to RFID tags and other small chips which can be used to transmit data between nearby devices - it is the type of technology behind ApplePay and Google Pay.  Essentially, an NFC chip can be encoded with a small amount of data (such as a URL, globally unique identifier, interpretive text about an object, etc). They are very inexpensive and easy to program which makes them ideal to place in collections for users to use a handheld device to trigger a website or find relevant information quickly.

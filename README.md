# PhraseNet

This is a phrase net implemented as a Shiny application. A phrase net is a visualization tool that represents a text input as a graph. The size of the text represents word frequency, connections between words are displayed as arrows where their directionality and width communicate the flow and strength of connected words. The user can select a custom connection word to be used between the words. The graph is created using the visNetwork infrastructure and reactive values in Shiny.

For example see accompanying Dracula.txt file initially downloaded via Project Gutenberg: https://www.gutenberg.org/ebooks/345

See an example below using the Dracula.txt and connector with "love". The graph displays the 51 most frequently connected words.

![This is an image](https://github.com/TheodorEmanuelsson/PhraseNet/blob/main/Phrasenet.png)


## Run the app

Run the following command:

`shiny::runGitHub("PhraseNet", "TheodorEmanuelsson")`

## Dependencies

The application depends on `shiny`, `shinydashboard`, `tidyr`, `tibble`, `tidytext`, `visNetwork`.

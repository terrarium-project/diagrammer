# Biosphere Diagrammer

Visually connect various processes to design closed-loop systems with desired production characteristics

This is an unfinished prototype.

## Usage

* Drag and drop components to place them in space
* The solid-colored chevron shapes attached to components are inputs and outputs -- inputs are on the left, outputs are on the right. Inputs can be attached to outputs and vice-versa.
* Once a system is set up, click the Run button to simulate the process. If any value goes below zero, the simulation will pause.


## Running in dev mode

First make sure you have a recent version of `npm` installed

1. Download and install the [Elm Platform](https://guide.elm-lang.org/get_started.html)
2. Clone or download this repo and `cd` to it
  - You can clone into the GitHub desktop app, and then Open In Terminal
  - or `git clone --recursive git://github.com/terrarium-project/diagrammer.git`
  - or `git clone --recursive git://github.com/terrarium-project/diagrammer.git && git submodule update --init`
3. `elm-package install`
4. `npm install`
5. `npm run dev`
6. Visit [http://localhost:3000](http://localhost:3000) in your browser

Changes to the source will be hot reloaded without losing the application state!

<h1 style="font-weight:normal" align="center">
  &nbsp;#30DayMapChallenge&nbsp;
</h1>

Hi! My name is Pablo and here are my contributions to the [#30DayMapChallenge](https://github.com/tjukanovt/30DayMapChallenge).

Feedback is very welcome via [Twitter](https://twitter.com/_egbg_).

## Table of Contents

<!-- TOC -->

- [Table of Contents](#table-of-contents)
- [Repository structure](#repository-structure)
- [Contributions](#contributions)
    - [Day 1: Points](#day-1-points)
    - [Day 2: Lines](#day-2-lines)
    - [Day 3: Polygons](#day-3-polygons)
    - [Day 4: Hexagons](#day-4-hexagons)
    - [Day 5: Blue](#day-5-blue)
<!-- /TOC -->

## Repository structure

Each day gets its own directory in the repository (01_Points, 02_Lines, ...). Inside, you'll find all the data and code necessary to replicate 
my maps.

Most of the maps were made using R.

## Contributions

### Day 1: Points

I plotted all bars, pubs, and [pulquerías](https://en.wikipedia.org/wiki/Pulque) in Mexico City —my home town. I used INEGI's DENUE (the National Directory of Economic Entities) and OpenStreetMap (for the road layout).

Maybe not all bar, pubs, and pulquerías in Mexico City are actually plotted here, since I found some errors in the database, but I did my best.

![./01_Points/Out/03_todos.jpeg](https://github.com/pablorm296/30DayMapChallenge/blob/master/01_Points/Out/03_todos.jpeg)

### Day 2: Lines

I plotted commuting links made inside Mexico City using exclusively three means of transport: bicycle, subway, and car.

For the data I used INEGI's Origin-Destination survey (2017) and OpenStreetMap —for the road layout.

It's interesting to see how the Mexico City subway has a small coverage, compared to Mexico City's road layout and to the commuting links made using a car.

![./02_Lines/Out/04_combinado.jpeg](https://github.com/pablorm296/30DayMapChallenge/blob/master/02_Lines/Out/08_combinado.jpeg)

### Day 3: Polygons

I plotted zoning, year of last renovation (or year of construction), and land value per square meter in my home borough (Iztapalapa) in Mexico City.

I used Mexico City's Open Geographic Information System.

![./03_Polygons/Out/05_valor.jpeg](https://github.com/pablorm296/30DayMapChallenge/blob/master/03_Polygons/Out/05_valor.jpeg)

### Day 4: Hexagons

I plotted AirBnb density in Mexico City. I used [Inside Airbnb](http://insideairbnb.com/about.html) as my main data source and Open Street Map for the road layout. 

As expected, the high Airbnb density areas are located in the most exclusive neighborhoods of the City: Polanco, La Condesa, and Colonia del Valle.

![./04_Hexagons/Out/05_todos.jpeg](https://github.com/pablorm296/30DayMapChallenge/blob/master/04_Hexagons/Out/05_todos.jpeg)

### Day 5: Blue

I plotted the index of flooding risk by block in Mexico City. The index of flooding risk is given by the floodable area as a percentage of the total block area. It's interesting to note that the higher risk areas are located in the basin of the [Lake Texcoco](https://en.wikipedia.org/wiki/Lake_Texcoco).

![./05_Blue/Out/04_texcoco.jpeg](https://github.com/pablorm296/30DayMapChallenge/blob/master/05_Blue/Out/04_texcoco.jpeg)

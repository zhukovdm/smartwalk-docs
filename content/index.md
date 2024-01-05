# Welcome to SmartWalk Docs

This page contains the documentation for [**SmartWalk**](https://www.github.com/zhukovdm/smartwalk), a web application for keyword-aware walking route search.

Check out the [**Demo**](https://smartwalk.vercel.app/) (although *not* connected to a backend) to get a sense of how the application might look and feel.

[**User's documentation**](./usr.md) gives an overview of how to use the application and accomplish basic tasks, such as searching for and managing entities.

[**Programmer's guide**](./prg.md) brings clarity into the application architecture and code organization. Code documentation for the frontend and backend can be accessed at [**prg-frontend**](./prg-frontend) and [**prg-backend**](./prg-backend), respectively.

[**Administrator's guide**](./adm.md) provides instructions for preparing a dataset, running the application in development or production mode on a personal computer, and troubleshooting potential issues.

## Motivation

Most of the mainstream web mapping applications ([Mapy.cz](https://mapy.cz/), [Google Maps](https://maps.google.com/), etc.) implement explicit location-based *direction* search. A typical workflow involves building a sequence, with the following three steps applied for *each* waypoint.

1. Search for places that might satisfy imposed constraints (e.g., a museum free of charge).
1. Append one of them to the sequence, with possible manual reordering.
1. New path is presented to the user right after the sequence configuration is altered.

In contrast, *SmartWalk* enables users to formulate search queries in terms of *categories*. A category is composed of a *keyword* (castle, museum, statue, etc.) and *attribute filters* (has an image, with WiFi, capacity &geq; *N*, etc.). For a place to be matched by a category, it must satisfy all constraints.

Given a starting point, destination, set of categories, and maximum walking distance, *SmartWalk* attempts to find *routes* with a length never longer than the predefined limit that visit at least one place from each category.

Besides routes, the application also supports *place* and standard location-based direction search.

## Credits

- The pictures and diagrams were created with [Draw.io](https://draw.io/) drawing software.

- Map tiles in the user interface are attributed to [&#169; OpenStreetMap](https://www.openstreetmap.org/copyright) contributors.

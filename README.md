# TriGuide

SwiftUI multi-module app for endurance training utilities.

## Overview

TriGuide is built with SwiftUI and modularized using Swift Package Manager (SPM). Feature domains live in their own packages, and shared cross-cutting concerns are extracted into reusable SPMs.

## Feature Modules

\* `RaceCalculatorSPM` \- Pace, speed, distance and time calculations for running (and potentially other sports).  
\* `CarbItemsSPM` \- Displays and manages carbohydrate intake items (including user items, search and filtering).

## Common (Shared) Modules

\* `DesignSystem` \- Fonts, colors, reusable SwiftUI components.  
\* `Localization` \- Localized strings and resources.  
\* `FormKit` \- Form models, validation, reusable form views.  
\* `NavigationKit` \- Navigation abstractions.  
\* `StorageKit` \- Local storage layer.  
\* `TriGuideDomain` \- Core entities (distance, sport, units) and protocols.

## Tech Stack

\* SwiftUI for UI layer.  
\* Swift Package Manager for modular boundaries.  
\* Async/await where applicable for data loading.  
\* Dependency inversion via use cases and repositories.

## Directory Snapshot (Simplified)

## Testing

Each SPM contains its own test target (unit tests per module), enabling isolated evolution.

## Extensibility

\* Add new sports by extending `TriGuideDomain` entities and units.  
\* Introduce new nutrition domains by adding a dedicated SPM under `Features/`.  
\* UI components should be contributed to `DesignSystem` to avoid duplication.

## License

Internal / TBD.

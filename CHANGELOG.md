## 0.11.2

- fixing `InApp` problem

## 0.11.2

- Adding request body converter

## 0.11.0

- better route handlers scanner

### Changes
- rename 'ReqCTX' to 'Request'
- rename 'BeforeMW' to 'UsePre'
- rename 'AfterMW' to 'UsePost'
- rename 'middlewares' to 'pipeline'
- changing routes tree system instead of of adding all function to routes stack the routes saved in stack with 'PathHandler' that contains spacific path and all handlers with this path and every handler has a method

### Deleted
- for now there is no indirect handlers and json, form or iForm handlers

## 0.9.0

### Added
- `InDirect` routes with query and json types `not recommended for now`

### Remove
- remove the database plugins

### Updating
- The `FormCTX` and `iFormCTX` to handle repeated fields

## 0.8.5

### Added
- `FormCTX` for encoded form content type request that only accept `application/x-www-form-urlencoded`
- `iFormCTX` for encoded form content type request that only accept `multipart/form-data`
- `Redirect` response
- Database integrations
- Plugins app

### Updates
- Updating cruky create command
- Better debug mode with production mode simulation

## 0.8.1

- fixing cruky cli
- rename `run` method to `runApp`
- updating hotreload

## 0.8.0

- adding content-type filtering option
- changing the handler types system and make it reuseable
- adding `JsonCTX` for json content type request that only accept `application/json`

## 0.7.1

- fix hot reload bug
- adding create command
- adding some docs

## 0.7.0

- Remove the cruky_cli
- Adding hot reload instead of auto reload
- adding `ServerApp` for the server settings
- adding multi threaded option with isolates in the release mode (Not in the debug mode)

## 0.6.0

- Changing the library design

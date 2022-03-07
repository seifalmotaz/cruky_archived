part of cruco.router;

@ERoute(404)
Map notFound() => {
      #status: 404,
      "status": 404,
      "msg": "Page not found",
    };

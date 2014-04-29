angular.module("vizBuilder", []).config ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).when("/datatables",
    templateUrl: "views/datatables.html"
    controller: "DatatableCtrl"
  ).when("/explorer",
    templateUrl: "views/explorer.html"
    controller: "ExplorerController"
  ).otherwise redirectTo: "/"

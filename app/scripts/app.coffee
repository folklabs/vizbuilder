
DATA_UNITY_URL = 'http://0.0.0.0:6543/api/beta'
DATA_UNITY_URL = 'http://dataunity.apiary-mock.com/api/beta'

vizBuilder = angular.module("vizBuilder", ['restangular'])

vizBuilder.config ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "/views/datatables.html"
    controller: "DatatableController"
  ).when("/datatables",
    templateUrl: "/views/datatables.html"
    controller: "DatatableController"
  ).when("/select-type",
    templateUrl: "/views/select-type.html"
    controller: "VisualizationTypeController"
  ).when("/select-columns",
    templateUrl: "/views/select-columns.html"
    controller: "ColumnsController"
  ).when("/visualization",
    templateUrl: "/views/visualization.html"
    controller: "VisualizationController"
  ).otherwise redirectTo: "/"


# Support CORS requests
# vizBuilder.config ['$httpProvider', ($httpProvider) ->
#   $httpProvider.defaults.useXDomain = true
#   delete $httpProvider.defaults.headers.common['X-Requested-With']
# ]
# Support CORS requests
vizBuilder.config ['$httpProvider', 'RestangularProvider', ($httpProvider, RestangularProvider) ->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  # RestangularProvider.setDefaultHeaders({
  #   'Content-Type': 'application/json',
  #   'X-Requested-With': 'XMLHttpRequest'
  # })
  # RestangularProvider.setDefaultHttpFields({
  #   'withCredentials': true
  # })
]

vizBuilder.config (RestangularProvider) ->
  url = DATA_UNITY_URL
  console.log window.data_unity_url
  if window.data_unity_url != undefined then url = window.data_unity_url
  RestangularProvider.setBaseUrl(url)

  RestangularProvider.addResponseInterceptor((data, operation, what, url, response, deferred) ->
    extractedData = data
    if (operation == "getList")
      extractedData = data.dataTable
    return extractedData
  )

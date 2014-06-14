
DATA_UNITY_URL = 'http://0.0.0.0:6543/api/beta'
# DATA_UNITY_URL = 'http://dataunity.apiary-mock.com/api/beta'
DATA_UNITY_URL = 'http://data-unity.com/api/beta'

# Create vizBuilder module
vizBuilder = angular.module("vizBuilder", ['restangular'])

vizBuilder.config ($routeProvider) ->
  # $rootScope =
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
# For some reason this seems to have to be here rather than in services
vizBuilder.config ['$httpProvider', 'RestangularProvider', ($httpProvider, RestangularProvider) ->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
]


vizBuilder.config (RestangularProvider) ->
  url = DATA_UNITY_URL
  console.log window.data_unity_url
  if window.data_unity_url != undefined then url = window.data_unity_url
  RestangularProvider.setBaseUrl(url)

  # Handle list being returned inside a wrapper object
  RestangularProvider.addResponseInterceptor((data, operation, what, url, response, deferred) ->
    extractedData = data
    if (operation == "getList")
      extractedData = data.dataTable
    return extractedData
  )

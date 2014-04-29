

vizBuilder = angular.module("vizBuilder")

vizBuilder.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']
]


vizBuilder.controller "DatatableCtrl", ($scope, datatableService) ->
  promise = datatableService.fetchTables()
  promise.then (data) ->
    $scope.datatables = data['dtbl:dataTable']
    console.log data


vizBuilder.controller "ExplorerController", ($scope, RendererService) ->
  $scope.renderers = RendererService.getRenderers()
  console.log $scope.renderers



vizBuilder = angular.module("vizBuilder")


STEPS = [
  'Datasets'
  'Visualization type'
  'Columns'
  'Visualize!'
]

vizBuilder.directive 'wizardProgressBar', ->
  restrict: 'AE'
  link: (scope, element, attrs) ->
    console.log 'directive wizardProgressBar'

    console.log attrs
    scope.activeStep = attrs.activeStep
    scope.steps = STEPS
    console.log 'scope'
    console.log scope
  templateUrl: 'views/wizard-progress-bar.html'


vizBuilder.controller "VizBuilderController", ($scope) ->
  console.log 'VizBuilderController'

vizBuilder.controller "DatatableController", ($scope, datatableService) ->
  $scope.select = (dataset) ->
    dataset.selected = !dataset.selected
    $scope.$parent.selectedDataset = dataset
    console.log $scope.$parent
    dataset.btnState = 'btn-success'
    dataset.btnState = 'btn-danger' if dataset.selected

  promise = datatableService.fetchTables()
  promise.then (data) ->
    $scope.datatables = data #['dtbl:dataTable']
    console.log data

    # TODO: temp hack!!
    # $scope.$parent.selectedDataset = data[0]


vizBuilder.controller "VisualizationTypeController", ($scope, RendererService, $http) ->
  $scope.renderers = RendererService.getRenderers()
  # console.log $scope.renderers

  $scope.saveRenderer = (renderer) ->
    console.log 'renderer'
    console.log renderer
    # console.log href
    $scope.$parent.selectedRenderer = renderer
    # $http.get(href).success((data) ->
    #   console.log href
    # )


vizBuilder.controller "ColumnsController", ($scope, datatableService, RendererService) ->
  console.log 'ColumnsController'
  console.log $scope.$parent.selectedDataset
  console.log $scope.$parent.selectedRenderer

  if ! $scope.$parent.selectedDataset.structure
    dtPromise = datatableService.fetchTable $scope.$parent.selectedDataset
    dtPromise.then (datatable) ->
      console.log 'fetchTable promise'
      console.log datatable
      # Replace the datatable reference with the full object
      $scope.$parent.selectedDataset = datatable
      $scope.structureAvailable = true
      # datatable.fetchFields()
    # $scope.$parent.selectedDataset.fetchFields()
  else
    $scope.structureAvailable = true

  $scope.selectColForField = (field, col) ->
    if col.selected == undefined
      col.selected = {}
    for c in $scope.$parent.selectedDataset['structure']['component']
      c.selected[field.vizField] = false if c.selected != undefined
    console.log field
    console.log col
    field.col = col
    col.selected[field.vizField] = ! col.selected[field.vizField]


vizBuilder.directive 'visualization', ->
  restrict: 'AE'
  link: (scope, element, attrs) ->
    console.log 'directive visualization'
    # console.log jsonSettingsTmp
    jsonSettings =
      "name": "default"
      "contentType": "text/csv"
      "fields": []

    console.log scope
    console.log scope.$parent.selectedDataset
    console.log scope.$parent.selectedRenderer
    jsonSettings['url'] = scope.$parent.selectedDataset['@id'] + '/raw'
    # TODO: Hardcoded dataset access
    for f in scope.$parent.selectedRenderer.datasets[0].fields
      console.log f.col
      fieldData =
        vizField: f.vizField
        dataField: f.col['fieldRef']
      jsonSettings.fields.push fieldData
    console.log 'jsonSettings:'
    console.log jsonSettings
    renderOpt =
      rendererName: scope.$parent.selectedRenderer['rendererName']
      # selector: "#vizshare"
      data: [jsonSettings]
      vizOptions: scope.$parent.selectedRenderer.vizOptions
    scope.$parent.vizshareDef = JSON.stringify([jsonSettings]);
    element.vizshare(renderOpt)


vizBuilder.controller "VisualizationController", ($scope, RendererService) ->
  $scope.renderers = RendererService.getRenderers()

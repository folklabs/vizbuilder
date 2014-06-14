

vizBuilder = angular.module("vizBuilder")


STEPS = [
  'Datasets'
  'Visualization type'
  'Columns'
  'Visualize!'
]

# Directive to initialize model for vizshareDef form field, setting up the model
# with any existing value if it is being used for editing.
# See http://www.neontsunami.com/post/initialise-angular-model-using-the-initial-value
# for more info.
vizBuilder.directive 'initModel', ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    console.log 'directive initModel'

    console.log element[0].value
    scope.vizshareDef = element[0].value
    element.attr 'ng-model', 'vizshareDef'
    element.removeAttr 'init-model'
    # scope.activeStep = attrs.activeStep
    # scope.steps = STEPS
    console.log 'scope'
    console.log scope

vizBuilder.directive 'wizardProgressBar', ->
  restrict: 'AE'
  link: (scope, element, attrs) ->
    console.log 'directive wizardProgressBar'

    console.log attrs
    scope.activeStep = attrs.activeStep
    scope.steps = STEPS
    console.log 'scope'
    console.log scope
  templateUrl: '/views/wizard-progress-bar.html'


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
    $scope.datatables = data
    console.log data

    # TODO: temp hack!!
    # $scope.$parent.selectedDataset = data[0]


vizBuilder.controller "VisualizationTypeController", ($scope, RendererService, $http) ->
  $scope.renderers = RendererService.getRenderers()
  # console.log $scope.renderers

  $scope.selectRenderer = (renderer) ->
    for r in $scope.renderers
      r.selected = false
    $scope.$parent.selectedRenderer = renderer
    renderer.selected = true


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
    vizType = scope.$parent.selectedRenderer.type
    jsonSettings =
      "name": "default"
      "contentType": "text/csv"
      "visualizationType": vizType
      "fields": []

    console.log scope
    console.log scope.$parent.selectedDataset
    console.log scope.$parent.selectedRenderer

    # Set the URL where to get the data
    jsonSettings['url'] = scope.$parent.selectedDataset['@id'] + '/raw'
    if vizType == 'vizshare.geoleaflet'
      jsonSettings['url'] = 'http://data-unity.com/api/beta/jobs/datatable-jobs/5a89e1e2-b11a-4b03-9910-8cf7eefe9c87'
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
      data: [jsonSettings]
      vizOptions: scope.$parent.selectedRenderer.vizOptions
    scope.$parent.vizshareDef = JSON.stringify([jsonSettings]);
    element.vizshare(renderOpt)


vizBuilder.controller "VisualizationController", ($scope, RendererService) ->
  $scope.renderers = RendererService.getRenderers()

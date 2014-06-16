

vizBuilder = angular.module("vizBuilder")


STEPS = [
  'Datasets'
  'Visualization type'
  'Columns'
  'Visualize!'
]

# -----------------------------------------------------------------------------
# Directives

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


# -----------------------------------------------------------------------------
# Controllers

vizBuilder.controller "VizBuilderController", ($scope) ->
  console.log 'VizBuilderController'


vizBuilder.controller "DatatableController", ($scope, DatatableService) ->
  $scope.select = (dataset) ->
    dataset.selected = !dataset.selected
    $scope.$parent.selectedDataset = dataset
    console.log $scope.$parent
    dataset.btnState = 'btn-success'
    dataset.btnState = 'btn-danger' if dataset.selected

  promise = DatatableService.fetchTables()
  promise.then (data) ->
    $scope.datatables = data
    # console.log data

    # TODO: remove! Testing hack to get one table
    # tablePromise = DatatableService.fetchTable $scope.datatables[0]
    # tablePromise.then (table) ->
    #   console.log 'table'
    #   console.log table
    #   table.getDataEndpoint( (data) ->
    #     console.log 'getDataEndpoint callback'
    #     console.log data
    #   )

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


vizBuilder.controller "ColumnsController", ($scope, DatatableService, RendererService) ->
  console.log 'ColumnsController'
  console.log $scope.$parent.selectedDataset
  console.log $scope.$parent.selectedRenderer

  if ! $scope.$parent.selectedDataset.structure
    dtPromise = DatatableService.fetchTable $scope.$parent.selectedDataset
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
  # transclude: true
  # template: '<div class="angular-leaflet-map"><div ng-transclude></div></div>'
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
    # jsonSettings['url'] = scope.$parent.selectedDataset['@id'] + '/raw'
    endPoint = scope.$parent.selectedDataset.getDataEndpoint( (endpoint) ->
      console.log endpoint
      jsonSettings['url'] = endpoint
      # jsonSettings['url'] = 'http://data-unity.com/api/beta/jobs/datatable-jobs/88232fde-267b-4eb2-a934-2e5b90ea93d4/tmp-output'

      # console.log 'endPoint'
      # console.log endPoint
      # endPoint.then (data) ->
      #   console.log 'data'
      #   console.log data
      #   jsonSettings['url'] = data.data

      # if vizType == 'vizshare.geoleaflet'
      #   jsonSettings['url'] = 'http://data-unity.com/api/beta/jobs/datatable-jobs/640320d8-cdda-43ef-97d5-98c9ffc8c69d/tmp-output'
      # TODO: Hardcoded dataset access
      for f in scope.$parent.selectedRenderer.datasets[0].fields
        console.log f.col
        fieldData =
          vizField: f.vizField
          dataField: f.col['fieldRef']
        jsonSettings.fields.push fieldData
      console.log 'jsonSettings:'
      console.log JSON.stringify(jsonSettings)

      # options =      {
      #     "scales": [
      #         {
      #             "name": "area",
      #             "type": "linear",
      #             "domain": {"data": "default", "vizField": "value"},
      #             "range": [50000, 100000]
      #         },
      #         {
      #             "name": "onetoten",
      #             "type": "linear",
      #             "domain": [1, 10],
      #             "range": [50000, 1000000]
      #         },
      #         {
      #             "name": "colours",
      #             "type": "linear",
      #             "domain": {"data": "default", "vizField": "value"},
      #             "range": ["red", "blue"]
      #         },
      #         {
      #             "name": "coloursonetoten",
      #             "type": "linear",
      #             "domain": [1, 10],
      #             "range": ["red", "blue"]
      #         }
      #     ],
      #     "marks": [
      #         {
      #             "type": "latlongcircle",
      #             "from": {"data": "default"},
      #             "properties": {
      #                 "enter": {
      #                     "lat": {"vizField": "lat"},
      #                     "long": {"vizField": "long"},
      #                     # "size": {"scale": "onetoten", "vizField": "value"},
      #                     "text": {"vizField": "title"},
      #                     "fill": {"scale": "colours", "vizField": "value"}
      #                 }
      #             }
      #         }
      #     ]
      # }
      # jsonSettings = {"name":"default","contentType":"text/csv","visualizationType":"map","fields":[{"vizField":"lat","dataField":"Latitude"},{"vizField":"long","dataField":"Longitude"},{"vizField":"title","dataField":"WARD"},{"vizField":"value","dataField":"LICENCE EXPIRY DATE"}],"url":"http://data-unity.com/api/beta/jobs/datatable-jobs/88232fde-267b-4eb2-a934-2e5b90ea93d4/tmp-output"}

      element.css 'width','900px'  #; height: 400px;'
      element.css 'height','500px'  #; height: 400px;'
      renderOpt =
        selector: '#map'
        # width: 500
        # height: 400
        rendererName: scope.$parent.selectedRenderer['rendererName']
        # rendererName: 'vizshare.geoleaflet'
        data: [jsonSettings]
        vizOptions: scope.$parent.selectedRenderer.vizOptions
        # vizOptions: options
      scope.$parent.vizshareDef = JSON.stringify([jsonSettings])
      # template: 'foo'
      element.vizshare(renderOpt)
    )

vizBuilder.controller "VisualizationController", ($scope, RendererService) ->
  $scope.renderers = RendererService.getRenderers()



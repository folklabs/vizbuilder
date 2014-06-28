

vizBuilder = angular.module("vizBuilder")

# Wizard steps config
STEPS = [
  {
    name: 'datasets'
    text: 'Select datasets'
  }
  {
    name: 'type'
    text: 'Select visualization type'
  }
  {
    name: 'columns'
    text: 'Select data columns'
  }
  {
    name: 'visualize'
    text: 'Edit visualization'
  }
]

AGGREGATION_METHODS = [
  "Count"
  "Sum"
  "Average"
  "Min"
  "Max"
  "First"
  "Last"
]


# -----------------------------------------------------------------------------
# Directives

# Directive to initialize model for vizDef form field, setting up the model
# with any existing value if it is being used for editing.
# See http://www.neontsunami.com/post/initialise-angular-model-using-the-initial-value
# for more info.
vizBuilder.directive 'initModel', ['$rootScope', '$compile', ($rootScope, $compile) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    console.log 'directive initModel'

    $rootScope.imagePath = element.attr 'image-path'
    console.log element[0].value
    scope.vizDef = element[0].value
    element.attr 'ng-model', 'vizDef'
    element.removeAttr 'init-model'
    $compile(element)(scope)
    # scope.activeStep = attrs.activeStep
    # scope.steps = STEPS
    console.log 'scope'
    console.log scope
  ]

vizBuilder.directive 'wizardProgressBar', ->
  restrict: 'AE'
  link: (scope, element, attrs) ->
    # console.log 'directive wizardProgressBar'
    # console.log attrs
    scope.activeStep = attrs.activeStep
    scope.steps = STEPS
  templateUrl: '/views/wizard-progress-bar.html'


# -----------------------------------------------------------------------------
# Controllers

vizBuilder.controller "VizDefController", ($scope, $rootScope) ->
  console.log 'VizDefController'
  $rootScope.state = {}

  # Copy vizDef info to make it accessible
  $rootScope.$watch('vizDef', (newVal, old) ->
    $scope.state.vizDef = newVal
  )


vizBuilder.controller "VizBuilderController", ($scope) ->
  console.log 'VizBuilderController'


vizBuilder.controller "DatatableController", ($scope, $rootScope, DatatableService) ->
  $scope.select = (dataset) ->
    dataset.selected = !dataset.selected
    $rootScope.state.dataset = dataset
    # console.log $$rootScope
    dataset.btnState = 'btn-primary'
    dataset.btnState = 'btn-danger' if dataset.selected

    # tablePromise = DatatableService.fetchTable dataset
    # tablePromise.then (table) ->
    #   console.log 'table'
    #   console.log table
    #   # table.createGroupAggregateDataTable 'Total Pay Floor (?)', 'Organisation'
    #   tableCreated = table.createGroupAggregateDataTable 'Country', 'Number'
    #   console.log tableCreated
    #   tableCreated.then (dataTableURL) ->
    #     console.log dataTableURL
    #     newTable = DatatableService.fetchTable {'@id': dataTableURL}
    #     console.log newTable

  tablesFetched = DatatableService.fetchTables()
  tablesFetched.then (data) ->
    console.log 'tablesFetched'
    $scope.datatables = data
    console.log data

    # data[0].fetchSources()

    # TODO: remove! Testing hack to get one table
    # tablePromise = DatatableService.fetchTable $scope.datatables[4]
    # tablePromise.then (table) ->
    #   console.log 'table'
    #   console.log table
    #   table.createGroupAggregateDataTable 'Total Pay Floor (?)', 'Organisation'
      # table.getDataEndpoint( (data) ->
      #   console.log 'getDataEndpoint callback'
      #   console.log data
      # )

    # TODO: temp hack!!
    # $$rootScope.state.dataset = data[0]


vizBuilder.controller "VisualizationTypeController", ($scope, $rootScope, RendererService, $http) ->
  $scope.renderers = RendererService.getRenderers()
  # console.log $scope.renderers

  $scope.selectRenderer = (renderer) ->
    console.log 'selectRenderer'
    for r in $scope.renderers
      r.selected = false
    $rootScope.state.renderer = renderer
    console.log $rootScope.state
    renderer.selected = true


vizBuilder.controller "ColumnsController", ($scope, $rootScope, DatatableService, RendererService) ->
  console.log 'ColumnsController'
  console.log $rootScope.state.dataset
  console.log $rootScope.state.renderer
  $scope.aggregationMethods = AGGREGATION_METHODS
  $rootScope.state.aggregationMethod = "Count"
  # $scope.selectedMethod = "Count"
  console.log $scope
  $scope.$watch 'state.aggregationMethod', (newVal) ->
    console.log 'aggregationMethod ' + newVal


  $scope.selectAggregationMethod = (method) ->
    $scope.selectedMethod = method

  # TODO: is any of this needed if structure is retrieved earlier?
  # if ! $$rootScope.state.dataset.structure
  #   dtPromise = DatatableService.fetchTable $$rootScope.state.dataset
  #   dtPromise.then (datatable) ->
  #     console.log 'fetchTable promise'
  #     console.log datatable
  #     # Replace the datatable reference with the full object
  #     $$rootScope.state.dataset = datatable
  #     $scope.structureAvailable = true
  #     # datatable.fetchFields()
  #   # $$rootScope.state.dataset.fetchFields()
  # else
  #   $scope.structureAvailable = true

  $scope.selectColForField = (field, col) ->
    if col.selected == undefined
      col.selected = {}
    for c in $rootScope.state.dataset['structure']['component']
      c.selected[field.vizField] = false if c.selected != undefined
    # console.log field
    # console.log col
    field.col = col
    col.selected[field.vizField] = ! col.selected[field.vizField]


vizBuilder.directive 'visualization', ['$rootScope', 'DatatableService', ($rootScope, DatatableService) ->
  restrict: 'AE'
  # transclude: true
  # template: '<div class="angular-leaflet-map"><div ng-transclude></div></div>'
  link: (scope, element, attrs) ->
    console.log 'directive visualization'
    console.log $rootScope.state.aggregationMethod
    vizType = $rootScope.state.renderer.type
    jsonSettings =
      "name": "default"
      "contentType": "text/csv"
      "visualizationType": vizType
      "fields": []
      "vizOptions": $rootScope.state.renderer.vizOptions

    # console.log scope
    # console.log $rootScope.state.dataset
    # console.log $rootScope.state.renderer

    dataset = $rootScope.state.renderer.datasets[0]
    dataTable = $rootScope.state.dataset
    # tableCreated = table.createGroupAggregateDataTable 'Country', 'Number'
    console.log dataset.fields[0].col['fieldRef']
    console.log dataset.fields[1].col['fieldRef']
    console.log dataTable

    groupField = dataset.fields[0].col['fieldRef']
    aggField = dataset.fields[1].col['fieldRef']
    aggType = $rootScope.state.aggregationMethod

    fieldNames = dataunity.querytemplate.groupAggregateDataTableFieldNames(groupField, aggField, aggType)
    console.log 'fieldNames'
    console.log fieldNames
    if dataset.type != 'geoleaflet'
      groupField = fieldNames.groupField
      aggField = fieldNames.aggField

    tableCreated = dataTable.createGroupAggregateDataTable groupField, aggField, aggType
    console.log tableCreated
    tableCreated.then (dataTableURL) ->
      console.log dataTableURL
      tableFetched = DatatableService.fetchTable {'@id': dataTableURL}
      console.log tableFetched
      tableFetched.then (pipeDataTable) ->
        # Set the URL where to get the data
        endPoint = pipeDataTable.getDataEndpoint (endpoint) ->
          # console.log endpoint
          jsonSettings['url'] = endpoint
          # TODO: Hardcoded dataset access
          for f in dataset.fields
            console.log f.col
            dataField = groupField
            if f.needsAggregate
              dataField = aggField
            fieldData =
              vizField: f.vizField
              dataField: dataField
            jsonSettings.fields.push fieldData
          # console.log 'jsonSettings:'
          # console.log JSON.stringify(jsonSettings)
          element.css 'width','900px'  #; height: 400px;'
          element.css 'height','500px'  #; height: 400px;'
          renderOpt =
            # TODO: check
            selector: '#map'
            # width: 500
            # height: 400
            rendererName: $rootScope.state.renderer['rendererName']
            # rendererName: 'vizshare.geoleaflet'
            data: [jsonSettings]
            vizOptions: $rootScope.state.renderer.vizOptions
            # vizOptions: options
          # console.log 'Setting vizDef...'

          $rootScope.vizDef = JSON.stringify([jsonSettings])
          # scope.state.vizDef = JSON.stringify([jsonSettings])
          # $rootScope.vizDef = JSON.stringify([jsonSettings])
          # console.log scope
          # console.log $rootScope
          # console.log $rootScope.vizDef
          $rootScope.state.vizRendered = true
          element.vizshare(renderOpt)
  ]

vizBuilder.controller "VisualizationController", ($scope, RendererService) ->
  $scope.renderers = RendererService.getRenderers()



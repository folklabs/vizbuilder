

vizBuilder = angular.module("vizBuilder")

# Wizard steps config
STEPS = [
  {
    name: 'datatables'
    text: 'Select datasets'
  }
  {
    name: 'select-type'
    text: 'Select visualization type'
  }
  {
    name: 'select-columns'
    text: 'Select data columns'
  }
  {
    name: 'visualization'
    text: 'Edit visualization'
  }
]

AGGREGATION_METHODS = [
  {name: "Count", description: 'Shows the total number of items'}
  {name: "Sum", description: 'Shows the sum of all the item values'}
  {name: "Average", description: 'Shows the mean average of all the item values'}
  {name: "Min", description: 'Shows the minimum value from all the item values'}
  {name: "Max", description: 'Shows the maximum value from all the item values'}
  {name: "First", description: 'Shows the first value in the list of values'}
  {name: "Last", description: 'Shows the last value in the list of values'}
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
    if $rootScope.state == undefined
      $rootScope.state = {}
    console.log $rootScope.state
    vizDefContent = element[0].value
    if vizDefContent != undefined
      vizDefContent = vizDefContent.replace /^\s+|\s+$/g, ""
    if vizDefContent.length > 0
      $rootScope.state.vizDef = JSON.parse vizDefContent
      $rootScope.state.edit = true
      console.log JSON.parse vizDefContent

    console.log $rootScope.state
    # element.attr 'ng-model', 'state.vizDef'
    element.removeAttr 'init-model'
    $compile(element)(scope)
    # scope.activeStep = attrs.activeStep
    # scope.steps = STEPS
    console.log '$rootScope'
    console.log $rootScope
  ]

vizBuilder.directive 'wizardProgressBar', ->
  restrict: 'AE'
  link: (scope, element, attrs) ->
    # console.log 'directive wizardProgressBar'
    # console.log attrs
    scope.activeStep = attrs.activeStep
    scope.steps = STEPS
    index = 0
    while scope.steps[index].name != scope.activeStep
      scope.steps[index].completed = true
      index += 1
  templateUrl: '/views/wizard-progress-bar.html'


# -----------------------------------------------------------------------------
# Controllers

vizBuilder.controller "VizDefController", ($scope, $rootScope) ->
  console.log 'VizDefController'
  if $rootScope.state == undefined
    $rootScope.state = {}

  # Copy vizDef info to make it accessible
  # $rootScope.$watch('vizDef', (newVal, old) ->
  #   console.log 'vizDef changing ' + newVal + ' ' + old
  #   # $scope.state.vizDef = newVal
  # )


vizBuilder.controller "VizBuilderController", ($scope) ->
  console.log 'VizBuilderController'


vizBuilder.controller "DatatableController", ($scope, $rootScope, DatatableService) ->
  $scope.select = (dataset) ->
    dataset.selected = !dataset.selected
    if dataset.selected
      $rootScope.state.dataset = dataset
    else
      $rootScope.state.dataset = undefined
    # console.log $$rootScope
    dataset.btnState = 'btn-primary'
    dataset.btnState = 'btn-danger' if dataset.selected

  if $scope.datatables == undefined
    tablesFetched = DatatableService.fetchTables()
    tablesFetched.then (data) ->
      console.log 'tablesFetched'
      $rootScope.datatables = data
      console.log data

      # Initialize existing state
      if $rootScope.state.edit and $rootScope.state.vizDef[0].datatable
        console.log 'Scanning to initialize datatable'
        for d in data
          if d['@id'] == $rootScope.state.vizDef[0].datatable['@id']
            $scope.select d




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
  $scope.selectRenderer = (renderer) ->
    console.log 'selectRenderer'
    for r in $scope.renderers
      r.selected = false
    $rootScope.state.renderer = renderer
    console.log $rootScope.state
    renderer.selected = true

  $scope.renderers = RendererService.getRenderers()
  # console.log $scope.renderers

  # Initialize existing state
  if $rootScope.state.edit and $rootScope.state.vizDef[0].visualizationType
    for r in $scope.renderers
      if r.type == $rootScope.state.vizDef[0].visualizationType
        $scope.selectRenderer r

vizBuilder.controller "ColumnsController", ($scope, $rootScope, DatatableService, RendererService) ->
  $scope.selectColForField = (field, col) ->
    console.log 'selectColForField'
    if col['selected'] == undefined
      col.selected = {}
    for c in $rootScope.state.dataset['structure']['component']
      c.selected[field.vizField] = false if c.selected != undefined
    console.log field
    console.log col
    field.col = col
    col.selected[field.vizField] = ! col.selected[field.vizField]

    # Check if all columns have been selected and we can move to next step
    isAllColumnsSelected = true
    for field in $rootScope.state.renderer.datasets[0].fields
      if field.col == undefined
        isAllColumnsSelected = false
    $scope.isAllColumnsSelected = isAllColumnsSelected

  # $scope.selectAggregationMethod = (method) ->
  #   $scope.selectedMethod = method

  console.log 'ColumnsController'
  console.log $rootScope.state.dataset
  console.log $rootScope.state.renderer
  $scope.aggregationMethods = AGGREGATION_METHODS
  $rootScope.state.aggregationMethod = "Count"
  $scope.a = {}
  # $scope.a.aggregationMethod = "Count"
  $scope.aggregationMethod = "Count"
  $scope.$watch 'state.aggregationMethod', (newVal, oldVal) ->
    console.log 'aggregationMethod ' + newVal

  # Initialize existing state
  if $rootScope.state.edit
    console.log $rootScope.state.vizDef
    for fieldMapping in $rootScope.state.vizDef[0].fields
      # console.log fieldMapping
      fieldMatch = undefined
      for field in $rootScope.state.renderer.datasets[0].fields
        # console.log field
        if field.vizField == fieldMapping.vizField
          fieldMatch = field
      colMatch = undefined
      for col in $rootScope.state.dataset['structure']['component']
        if col.fieldRef == fieldMapping.fieldRefLabel
          colMatch = col
      if fieldMatch != undefined and colMatch != undefined
        $scope.selectColForField fieldMatch, colMatch
      else
        console.log 'Existing state: field match failed: ' + fieldMatch + ', ' + colMatch



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




vizBuilder.directive 'visualization', ['$rootScope', 'DatatableService', ($rootScope, DatatableService) ->
  restrict: 'AE'
  # transclude: true
  # template: '<div class="angular-leaflet-map"><div ng-transclude></div></div>'
  link: (scope, element, attrs) ->
    console.log 'directive visualization'

    element.css 'width','900px'  #; height: 400px;'
    element.css 'height','500px'  #; height: 400px;'
    # console.log $rootScope.state.aggregationMethod
    vizType = $rootScope.state.renderer.type
    vizDef =
      "name": "default"
      "contentType": "text/csv"
      "visualizationType": vizType
      "fields": []
      "vizOptions": $rootScope.state.renderer.vizOptions
      datatable:
        '@id': $rootScope.state.dataset['@id']

    # console.log scope
    # console.log $rootScope.state.dataset
    # console.log $rootScope.state.renderer

    dataset = $rootScope.state.renderer.datasets[0]
    dataTable = $rootScope.state.dataset
    # tableCreated = table.createGroupAggregateDataTable 'Country', 'Number'
    console.log dataset.fields[0].col['fieldRef']
    console.log dataset.fields[1].col['fieldRef']
    console.log dataTable

    renderOpt =
      # TODO: check
      selector: '#map'
      # width: 500
      # height: 400
      rendererName: $rootScope.state.renderer['rendererName']
      # rendererName: 'vizshare.geoleaflet'
      # data: [vizDef]
      vizOptions: $rootScope.state.renderer.vizOptions

    if $rootScope.state.renderer.type != 'geoleaflet'
      console.log 'Getting endpoint for a chart'
      groupDataField = null
      aggDataField = null
      for f in dataset.fields
        if f.needsGroup
          groupDataField = f.col['fieldRef']
        if f.needsAggregate
          aggDataField = f.col['fieldRef']

      # groupField = dataset.fields[0].col['fieldRef']
      # aggField = dataset.fields[1].col['fieldRef']
      aggType = $rootScope.state.aggregationMethod

      fieldNames = dataunity.querytemplate.groupAggregateDataTableFieldNames(groupDataField, aggDataField, aggType)
      # console.log 'fieldNames'
      console.log fieldNames

      groupField = fieldNames.groupField
      aggField = fieldNames.aggField

      # Set new name in data fields
      for f in dataset.fields
        f.vizDataFieldName = f.col['fieldRef']
        if f.needsGroup
          f.vizDataFieldName = fieldNames.groupField
        if f.needsAggregate
          f.vizDataFieldName = fieldNames.aggField

      console.log dataset

      tableCreated = dataTable.createGroupAggregateDataTable groupDataField, aggDataField, aggType
      console.log tableCreated
      tableCreated.then (dataTableURL) ->
        $rootScope.progressWidth = 'width: 50%'
        console.log dataTableURL
        tableFetched = DatatableService.fetchTable {'@id': dataTableURL}
        console.log tableFetched
        tableFetched.then (pipeDataTable) ->
          console.log 'tableFetched'
          console.log pipeDataTable
          vizDef['datatable_url'] = dataTableURL

          # Set the URL where to get the data
          pipeDataTable.getDataEndpoint (endpoint, status) ->
            if status != 'completed'
              console.log 'Error! Status = ' + status
              $rootScope.state.status = 'error'
            # console.log endpoint
            $rootScope.progressWidth = 'width: 80%'
            vizDef['url'] = endpoint
            # TODO: Hardcoded dataset access
            for f in dataset.fields
              console.log f.col
              # dataField = groupField
              # if f.needsAggregate
              #   dataField = aggField
              fieldData =
                vizField: f.vizField
                dataField: f.vizDataFieldName
                fieldRefLabel: f.col['fieldRef']
              vizDef.fields.push fieldData
            # console.log 'vizDef:'
            # console.log JSON.stringify(vizDef)
            renderOpt.data = [vizDef]

              # vizOptions: options
            # console.log 'Setting vizDef...'

            $rootScope.state.vizDef = [vizDef]
            # scope.state.vizDef = JSON.stringify([vizDef])
            # $rootScope.vizDef = JSON.stringify([vizDef])
            # console.log scope
            # console.log $rootScope
            console.log $rootScope.state.vizDef
            $rootScope.state.vizRendered = true
            element.vizshare(renderOpt)
    else
      console.log 'Getting endpoint for a map'
      vizDef['datatable_url'] = dataTable['@id']
      dataTable.getDataEndpoint (endpoint) ->
        $rootScope.progressWidth = 'width: 80%'
        # console.log endpoint
        # vizDef['url'] = endpoint
        # TODO: Hardcoded dataset access
        for f in dataset.fields
          console.log f.col
          # dataField = groupField
          # if f.needsAggregate
          #   dataField = aggField
          fieldData =
            vizField: f.vizField
            dataField: f.col['fieldRef']
          vizDef.fields.push fieldData
        # console.log 'vizDef:'
        # console.log JSON.stringify(vizDef)
        renderDef = angular.copy vizDef
        renderDef['url'] = endpoint
        renderOpt.data = [renderDef]

          # vizOptions: options
        console.log 'Setting vizDef...'
        console.log vizDef
        console.log renderDef

        # $rootScope.state.vizDef = JSON.stringify([vizDef])
        $rootScope.state.vizDef = [vizDef]
        # $rootScope.vizDef = JSON.stringify([vizDef])
        # console.log scope
        # console.log $rootScope
        # console.log $rootScope.vizDef
        $rootScope.state.vizRendered = true
        element.vizshare(renderOpt)
  ]

vizBuilder.controller "VisualizationController", ($scope, $rootScope, RendererService) ->
  $scope.handleFormSubmit = () ->
    console.log 'handleFormSubmit'
    $rootScope.vizDefText = JSON.stringify $rootScope.state.vizDef

  $scope.renderers = RendererService.getRenderers()
  $rootScope.progressWidth = 'width: 20%'



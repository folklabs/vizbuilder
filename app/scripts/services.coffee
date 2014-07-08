
# DATA_UNITY_URL = 'http://0.0.0.0:6543/'
# DATA_UNITY_URL = 'http://data-unity.com/'


vizBuilder = angular.module('vizBuilder')


vizBuilder.config (RestangularProvider) ->
  # Handle list being returned inside a wrapper object
  RestangularProvider.addResponseInterceptor((data, operation, what, url, response, deferred) ->
    # console.log url
    extractedData = data

    if (operation == "getList")
      # console.log extractedData
      if url.match 'datatablecatalogs'
        extractedData = data.dataTable
      else if url.match 'sources-datasets'
        # Fix so no need for array wrapper
        extractedData = [data.dataset]
    # console.log extractedData.structure
    # extractedData.structure2 = extractedData.structure
    return extractedData
  )

# console.log 'vizBuilder'
vizBuilder.factory 'DatatableService', ($q, $timeout, $http, Restangular, $rootScope) ->

  # Add ability to also get fields for a single datatable REST object model
  Restangular.extendModel('datatables', (model) ->
    # Add ability to pull the field information into the datatable data
    # model.fetchFields = () ->
    #   # console.log 'fetchFields'
    #   # console.log model
    #   if !model.structData
    #     structureDefURL = model['structure']
    #     # console.log structureDefURL
    #     id = structureDefURL.substring structureDefURL.lastIndexOf('/') + 1
    #     # console.log id
    #     structPromise = Restangular.one('qb/datastructdefs', id).get()
    #     structPromise.then (structData) ->
    #       # console.log structData
    #       model.structure = structData

    model.fetchSources = () ->
      gotDatasets = this.all('sources-datasets').getList()
      gotDatasets.then (data) ->
        # console.log data
        model.source = data[0]
        # console.log model

    model.createGroupAggregateDataTable = (groupField, aggField, aggType) ->
      deferred = $q.defer()
      # TODO: fix
      dataunity.config.setBaseUrl 'http://data-unity.com' #window.data_unity_url

      tableCreated = dataunity.querytemplate.createGroupAggregateDataTable 'name', this['@id'], groupField, aggField, aggType
      tableCreated.done (dataTableURL) ->
        # console.log 'dataTableURL'
        # console.log dataTableURL
        # console.log deferred
        $rootScope.$apply deferred.resolve(dataTableURL)
        # this.fetchTable {'@id': dataTableURL}
      return deferred.promise

    model._poll = (url, callback) ->
      console.log 'poll: ' + url
      $http.get(url, {timeout: 1000}).
        success((data, status, headers, config) ->
          console.log 'success: ' + status + ' ' + data.status
          if (data.status == 'completed')
            callback(data.data)
          else
            $timeout () ->
              console.log 'waiting...'
              model._poll(url, callback)
            , 1000
        ).
        error((data, status, headers, config) ->
          if (status == 404)
            console.log("404 error, going to try again")
            $timeout () ->
              model._poll(url, callback)
            , 1000
          else
            console.log(data)
        )

    model.getDataEndpoint = (callback) ->
      console.log 'getDataEndpoint'
      console.log this['@id']
      # console.log this
      url = window.data_unity_url + '/jobs/datatable-jobs'
      console.log url
      # dataIn = JSON.stringify {"dataTable": this['@id']}
      dataIn = {"dataTable": this['@id']}
      $http.post(url, dataIn, {cache: false, timeout: 19000}).
        success((data, status, headers, config) ->
          console.log 'success (creating a job)'
          jobID = headers()['location'].replace url, ''
          jobID = jobID.replace '/', ''
          console.log jobID
          jobUrl = window.data_unity_url + '/jobs/datatable-jobs/' + jobID
          model._poll(jobUrl, callback)
        ).
        error((dataE, statusE, headersE, configE) ->
          console.log 'error!'
          console.log statusE
          console.log headersE
          console.log dataE
          console.log configE
          # $http.post(url, dataIn, {timeout: 2000}).
          #   success((data, status, headers, config) ->
          #     console.log 'success 2'
          #     @poll(data, status, headers, config, callback)
          #   ).
          #   error((data, status, headers, config) ->
          #     console.log 'error! again'
          #   )
        )

      # jobs = Restangular.all('jobs/datatable-jobs')
      # Restangular.setFullResponse true
      # newJob = jobs.post {"dataTable": this['@id']}
      # Restangular.setFullResponse false
      # console.log 'newJob.headers'
      # # console.log newJob.headers
      # console.log newJob
      # newJob.then (data) ->
      #   console.log 'data.headers'
      #   console.log data.headers

    return model
  )

  fetchTables: () ->
    deferred = $q.defer()
    gotList = Restangular.all('datatablecatalogs/public').getList()
    # Map the list of datasets into a set of Restangular objects
    gotList.then (data) ->
      dataTables = data.map (tableRef) ->
        console.log tableRef['@id']
        tableURL = tableRef['@id']
        id = tableURL.substring tableURL.lastIndexOf('/') + 1
        # dtPromise = Restangular.one('datatables', id).get()
        dataTable = Restangular.one('datatables', id)
        dataTable['@id'] = tableRef['@id']
        dataTable.label = tableRef.label
        dataTable.get({retrieve: 'structure'}).then (dataTableData) ->
          # This pattern is assigning back the useful data into original dataTable
          # Restangular object. May not be the most effective way to do this.
          dataTable.structure = dataTableData.structure
          # console.log 'dataTable2.structure'
          # console.log dataTable.structure
          # console.log dataTable2
          # console.log dataTable2.structure2
          # console.log dataTable.label
          dataTable.fetchSources()
          # return dataTable2
        return dataTable
      console.log $rootScope
      # $rootScope.$apply deferred.resolve(dataTables)
      $timeout () -> deferred.resolve(dataTables)
    return deferred.promise

  fetchTable: (tableRef) ->
    console.log 'fetchTable'
    tableURL = tableRef['@id']
    id = tableURL.substring tableURL.lastIndexOf('/') + 1
    dtPromise = Restangular.one('datatables', id).get({retrieve: 'structure'})
    # dtPromise.then (datatable) ->
    #   console.log 'fetchFields promise'
    #   datatable.fetchFields()
    return dtPromise


renderers = [
  {
    rendererName: 'vizshare.barchart'
    label: 'Bar chart'
    description: 'A bar chart or bar graph is a chart with rectangular bars with lengths proportional to the quantitative values that they represent.'
    type: 'barchart'
    thumbnail: '/images/thmb-barchart-245px.png'
    datasets: [
      name: 'dataset1'
      fields: [
        {
          vizField: 'xAxis'
          dataType: ['string']
          label: "X axis"
          description: "This defines the horizontal labels"
          required: true
          needsGroup: true
        }
        {
          vizField: 'yAxis'
          dataType: ['decimal']
          label: "Y axis"
          description: "This defines the size each bar"
          required: true
          needsAggregate: true
        }
      ]
    ]
    vizOptions: {}
  }
  {
    rendererName: 'vizshare.piechart'
    label: 'Pie chart'
    description: 'A pie chart is a circular chart divided into sectors, illustrating numerical proportion. In a pie chart, the arc length of each sector (and consequently its central angle and area), is proportional to the quantity it represents.'
    type: 'piechart'
    thumbnail: '/images/thmb-donutchart-245px.png'
    datasets: [
      name: 'dataset1'
      fields: [
        {
          vizField: 'name'
          dataType: ['string']
          label: "Name"
          description: "This defines the label of a segment"
          required: true
          needsGroup: true

        }
        {
          vizField: 'value'
          dataType: ['decimal']
          label: "Value"
          description: "This defines the size of a segment"
          required: true
          needsAggregate: true
        }
      ]
    ]
    vizOptions: {}
  }
  {
    rendererName: 'vizshare.geoleaflet'
    label: 'Map plot'
    description: 'Maps are symbolic depictions highlighting the relationships between elements such as objects, regions and themes within a territorial space.'
    type: 'geoleaflet'
    thumbnail: '/images/thmb-map-location-245px.png'
    datasets: [
      name: 'dataset1'
      "fields": [
        {
            "vizField": "lat"
            "label": "Latitude"
            "description": "This defines the horizontal position on the map"
            "dataField": "Lat"
        },
        {
            "vizField": "long"
            "label": "Longitude"
            "description": "This defines the vertical position on the map"
            "dataField": "Long"
        },
        {
            "vizField": "title"
            "label": "Title"
            "description": "The content of the popup."
            "dataField": "Name"
        },
        {
            "vizField": "value"
            "label": "Value"
            "description": ""
            "dataField": "Value"
        }
      ]
    ]
    vizOptions: {
        "scales": [
            {
                "name": "area",
                "type": "linear",
                "domain": {"data": "default", "vizField": "value"},
                "range": [50000, 100000]
            },
            {
                "name": "onetoten",
                "type": "linear",
                "domain": [1, 10],
                "range": [50000, 1000000]
            },
            {
                "name": "colours",
                "type": "linear",
                "domain": {"data": "default", "vizField": "value"},
                "range": ["red", "blue"]
            },
            {
                "name": "coloursonetoten",
                "type": "linear",
                "domain": [1, 10],
                "range": ["red", "blue"]
            }
        ],
        "marks": [
            {
                "type": "latlongcircle",
                "from": {"data": "default"},
                "properties": {
                    "enter": {
                        "lat": {"vizField": "lat"},
                        "long": {"vizField": "long"},
                        # "size": {"scale": "onetoten", "vizField": "value"},
                        "text": {"vizField": "title"},
                        "fill": {"scale": "colours", "vizField": "value"}
                    }
                }
            }
        ]
    }
  }
]

vizBuilder.factory 'RendererService', () ->
  # datatableService = {}
  getRenderers: () ->
    return renderers

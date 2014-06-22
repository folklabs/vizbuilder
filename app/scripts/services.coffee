
# DATA_UNITY_URL = 'http://0.0.0.0:6543/'
# DATA_UNITY_URL = 'http://data-unity.com/'


vizBuilder = angular.module('vizBuilder')


# console.log 'vizBuilder'
vizBuilder.factory 'DatatableService', ($q, $timeout, $http, Restangular, $rootScope) ->

  # Add ability to also get fields for a single datatable REST object model
  Restangular.extendModel('datatables', (model) ->
    # Add ability to pull the field information into the datatable data
    model.fetchFields = () ->
      # console.log 'fetchFields'
      # console.log model
      if !model.structData
        structureDefURL = model['structure']
        # console.log structureDefURL
        id = structureDefURL.substring structureDefURL.lastIndexOf('/') + 1
        # console.log id
        structPromise = Restangular.one('qb/datastructdefs', id).get()
        structPromise.then (structData) ->
          # console.log structData
          model.structure = structData

    model.createGroupAggregateDataTable = (groupField, aggField) ->
      deferred = $q.defer()
      # TODO: fix
      dataunity.config.setBaseUrl 'http://data-unity.com' #window.data_unity_url
      tableCreated = dataunity.querytemplate.createGroupAggregateDataTable 'name', this['@id'], groupField, aggField
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
          console.log 'success'
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
      # dataIn = JSON.stringify {"dataTable": this['@id']}
      dataIn = {"dataTable": this['@id']}
      $http.post(url, dataIn, {cache: false, timeout: 3000}).
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
    promise = Restangular.all('datatablecatalogs/public').getList()
    return promise

  fetchTable: (tableRef) ->
    console.log 'fetchTable'
    tableURL = tableRef['@id']
    id = tableURL.substring tableURL.lastIndexOf('/') + 1
    dtPromise = Restangular.one('datatables', id).get()
    dtPromise.then (datatable) ->
      console.log 'fetchFields promise'
      datatable.fetchFields()
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
          required: true
        }
        {
          vizField: 'yAxis'
          dataType: ['decimal']
          required: true
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
          required: true
        }
        {
          vizField: 'value'
          dataType: ['decimal']
          required: true
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
            "vizField": "lat",
            "dataField": "Lat"
        },
        {
            "vizField": "long",
            "dataField": "Long"
        },
        {
            "vizField": "title",
            "dataField": "Name"
        },
        {
            "vizField": "value",
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

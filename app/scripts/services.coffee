
DU_API = 'http://localhost:6543/api/beta/'


vizBuilder = angular.module('vizBuilder')


# console.log 'vizBuilder'
vizBuilder.service 'datatableService', ($q, $timeout, $http) ->
  # datatableService = {}
  this.fetchTables = () ->
    deferred = $q.defer()
    $timeout( () ->
      $http.get(DU_API + 'datatablecatalogs/public').success((data) ->
        deferred.resolve(data)
      )
    )
    return deferred.promise

    # tables = [{'name': 'lambeth crime', 'category': 'crime'}]
    # return tables


renderers = [
  {
    rendererName: 'dataunity.barchart'
    thumbnail: '/images/chart_bar.png'
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
  }
  {
    rendererName: 'dataunity.piechart'
    thumbnail: '/images/chart_pie.png'
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
  }
]
vizBuilder.service 'RendererService', () ->
  # datatableService = {}
  this.getRenderers = () ->
    return renderers

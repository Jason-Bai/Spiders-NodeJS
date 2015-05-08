_       = require 'underscore'
async   = require 'async'
request = require 'request'
$       = require 'cheerio'
load    = $.load

urls = [
  'http://movie.douban.com/subject/11529526'
  'http://movie.douban.com/subject/11529527'
  'http://movie.douban.com/subject/11529528'
  'http://movie.douban.com/subject/11529529'
  'http://movie.douban.com/subject/11529530'
]

translator =
  '名称': 'name'
  '海报': 'poster'
  '导演': 'doctor'
  '编剧': 'writer'
  '主演': 'actor'
  '类型': 'category'
  '制片国家/地区': 'country'
  '语言': 'language'
  '上映日期': 'releaseTime'
  '片长': 'time'
  '又名': 'alias'
  'IMDb链接': 'linkId'

execSpider = (url, cb) ->
  async.waterfall [
    (callback) ->
      request url, (err, r, body) ->
        way =
          body: body
        callback null, way
    , (way, callback) ->
      way.$ = load way.body
      callback null, way
    , (way, callback) ->
      $ = load way.body
      name = $('[property="v:itemreviewed"]').text()
      poster = $('img[rel="v:image"]').attr('src')
      text = $('#info').text()
      arr = text.split '\n'
      arr = _.filter arr, (v) ->
         v = v.replace /^\s+|\s+$/g, ''
         v if v isnt ''
      movie = {}
      _.each arr, (v) ->
        kw = v.split ':'
        key = kw[0].replace /^\s+/g, ''
        value = kw[1]
        movie[translator[key]] = value
      movie[translator['名称']] = name
      movie[translator['海报']] = poster
      way.movie = movie
      callback null, way
  ], (err, way) ->
    cb err ,way

async.each urls, (url, callback) ->
  execSpider url, (e, way) ->
    console.log way.movie
, (err) ->
  console.log 'work done'

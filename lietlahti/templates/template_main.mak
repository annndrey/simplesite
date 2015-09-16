## -*- coding: utf-8 -*-

<%inherit file="lietlahti:templates/template_base.mak"/>

  

<!--  <div class="inner">
    <div class="col-md-10 col-md-offset-1" align='justify'>
      <div id="map" style="height: 335px">
	<script>
	 var map = L.map('map').setView([51.505, -0.09], 1);
	 L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
	   maxZoom: 18,
	   attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
		     '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
		     'Imagery © <a href="http://mapbox.com">Mapbox</a>',
	   id: 'annndrey.kg994dgi'
	 }).addTo(map);
	 % for art in articles:
           % if art.status not in ('draft', 'private'):
	      % if art.lat is not None:
	         L.marker([${art.lat}, ${art.lon}]).addTo(map).bindPopup('<div class="thumbnail"><img alt="" class="media-object img-rounded" src="${art.previewpict}" width="140"/><div class="caption"><a href="${request.route_url('article', url=art.url)}">${art.mainname}</a><p>${art.descr}  :${art.status}:</p></div></div>');
	 % endif
	 % endif
	 % endfor
       var popup = L.popup();
       function onMapClick(e) {
	 popup
	    .setLatLng(e.latlng)
	    .setContent("You clicked the map at " + e.latlng.toString())
	    .openOn(map);
       }
       map.on('click', onMapClick);
      </script>
    </div>
  </div>
-->
  <div class="row">
    <div class="col-md-8 col-md-offset-2" align='justify'>
      % if articles:
	% for a in articles:
	  % if auth:
	    % if a.status == 'draft': 
	      <div class="media">
		##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
		##  <img alt='' class="media-object img-rounded" src="${a.previewpict}" width="140"/>
		##</a>
		<div class="media-body">
		  <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [${a.user}]</small></h4>
		  <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		  <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
	      
		  <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		    <div class="modal-dialog">
		      <div class="modal-content">
			<div class="modal-header">
			  <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
			  <h4 class="modal-title" id="modalRemoveLabel">Удаление статьи</h4>
			</div>
			<div class="modal-body">
			  Вы действительно хотите удалить статью <strong>"${a.mainname}"</strong>?
			</div>
			<div class="modal-footer">
			  <button type="button" class="btn btn-default" data-dismiss="modal">Отмена</button>
			  <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">Удалить</a>
			</div>
		      </div>
		    </div>
		  </div>
		  % if a.previewtext is not None:
		    <small>${a.previewtext}</small>
		  % else:
		    ...
		  % endif
		</div>
	      </div>
	    % endif  
	    % if a.status == 'private':

	      <div class="media">
		##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
		##  <img alt='' class="media-object img-rounded" src="${a.previewpict}" width="140"/>
		##</a>
		<div class="media-body">
		  <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [${a.user}]</small></h4>
		  <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		  <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
		  
		  <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		    <div class="modal-dialog">
		      <div class="modal-content">
			<div class="modal-header">
			  <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
			  <h4 class="modal-title" id="modalRemoveLabel">Удаление статьи</h4>
			</div>
			<div class="modal-body">
			  Вы действительно хотите удалить статью <strong>"${a.mainname}"</strong>?
			</div>
			<div class="modal-footer">
			  <button type="button" class="btn btn-default" data-dismiss="modal">Отмена</button>
			  <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">Удалить</a>
			</div>
		      </div>
		    </div>
		  </div>  
		  % if a.previewtext is not None:
		    <small>${a.previewtext}</small>
		  % else:
		    ...
		  % endif
		</div>
	      </div>
	      
	    % endif
	  % endif 
	  
	  % if a.status == "ready":
	    <div class="media">
	      ##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
              ##<img alt='' class="media-object img-rounded pull-left" src="${a.previewpict}" width="140"/>
	      ##</a>
	      <div class="media-body">
		<h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a></h4>
		% if auth:
		  <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		  <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
		  
		  <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		    <div class="modal-dialog">
		      <div class="modal-content">
			<div class="modal-header">
			  <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
			  <h4 class="modal-title" id="modalRemoveLabel">Удаление статьи</h4>
			</div>
			<div class="modal-body">
			  Вы действительно хотите удалить статью <strong>"${a.mainname}"</strong>?
			</div>
			<div class="modal-footer">
			  <button type="button" class="btn btn-default" data-dismiss="modal">Отмена</button>
			  <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">Удалить</a>
			</div>
		      </div>
		    </div>
		  </div>
		% endif

		% if a.previewtext is not None:
		  <small>${a.previewtext}</small>
		% else:
		  ...
		% endif
	      </div>
	    </div>
	  % endif
	  
	% endfor  
      % else:
	There's no articles yet. 
      % endif  	
    </div>
  </div>
</div>



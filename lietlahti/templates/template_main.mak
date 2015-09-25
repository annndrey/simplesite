## -*- coding: utf-8 -*-

<%inherit file="lietlahti:templates/template_base.mak"/>
  <img class="img-responsive img-rounded hidden-xs" src="http://pomoyka.homelinux.net/immortal/94577fb5-7842-4681-8d24-1bba4b6e8ca8.png">
  <p> </p>
  <div class="row">
    <div class="col-md-12 " align='justify'>
      % if articles:
	% for a in articles:
          % if a.series != 'mainpage':
	    % if auth:
	      % if a.status == 'draft': 
	        <div class="media">
		  ##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
		  ##  <img alt='' class="media-object img-rounded" src="${a.previewpict}" width="140"/>
		  ##</a>
		  <div class="media-body">
		    <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [by ${a.user}]
		    <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		    <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
	            </small></h4>
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
		    <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [by ${a.user}]
		    <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		    <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
		    </small></h4>
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
		  <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.mainname}</a>
		  % if auth:
                    <small>
		    <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">Править</a>
		    <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">Удалить</a>
		    </small></h4>
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
	  % endif
	% endfor  
      % else:
	There's no articles yet. 
      % endif  	
    </div>
  </div>
</div>



## -*- coding: utf-8 -*-

<%inherit file="lietlahti:templates/template_base.mak"/>
<div class="jumbotron">
    <h2 class="text-center">${_('Природно-этнографический парк «Лиетлахти»')}</h2>
    <p>${_('Экотуризм, скалолазание, приключенческий туризм, семейный отдых, размещение в кемпинге или фермерском доме.')}</p>
    <div class="col-xs-12" style="height:50%;"></div>
    <p><span class="glyphicon glyphicon-hand-right"></span> <a href="/article/contacts" role="button">${_('Как к нам попасть?')}</a></p>
    <p><span class="glyphicon glyphicon-hand-right"></span> <a href="/article/prices" role="button">${_('Размещение и аренда')}</a></p>
</div>

<div class="row">
    <div class="col-md-12 " align='justify'>
        % if articles:
	    % for a in articles:
                % if a.series != 'mainpage':
	            % if auth:
	                % if a.status == 'draft':
                            % if a.user == authuser or user.admin == 1: 
	                        <div class="media">
		                    <div class="media-body">
		                        <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.getvalue("mainname", lang)}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [by ${a.user}]
		                            <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">${_('Править')}</a>
		                            <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">${_('Удалить')}</a>
	                                </small></h4>
		                        <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		                            <div class="modal-dialog">
		                                <div class="modal-content">
			                            <div class="modal-header">
			                                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">${_('Закрыть')}</span></button>
			                                <h4 class="modal-title" id="modalRemoveLabel">${_('Удаление статьи')}</h4>
			                            </div>
			                            <div class="modal-body">
			                                ${_('Вы действительно хотите удалить статью')} <strong>"${a.getvalue("mainname", lang)}"</strong>?
			                            </div>
			                            <div class="modal-footer">
			                                <button type="button" class="btn btn-default" data-dismiss="modal">${_('Отмена')}</button>
			                                <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">${_('Удалить')}</a>
			                            </div>
		                                </div>
		                            </div>
		                        </div>
		                        % if a.getvalue("previewtext", lang) is not None:
		                            <small>${a.getvalue("previewtext", lang)}</small>
		                        % else:
		                            ${_('Ничего нет...')}
		                        % endif
		                    </div>
	                        </div>
                            % endif
	                % endif  
                        
	                % if a.status == 'private':
                            % if a.user == authuser or user.admin == 1: 
	                        <div class="media">
		                    ##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
		                    ##  <img alt='' class="media-object img-rounded" src="${a.previewpict}" width="140"/>
		                    ##</a>
		                    <div class="media-body">
		                        <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.getvalue("mainname", lang)}</a> <small><span class="label label-default"> ${statuses[a.status]}</span> [by ${a.user}]
		                            <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">${_('Править')}</a>
		                            <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">${_('Удалить')}</a>
		                        </small></h4>
		                        <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		                            <div class="modal-dialog">
		                                <div class="modal-content">
			                            <div class="modal-header">
			                                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
			                                <h4 class="modal-title" id="modalRemoveLabel">${_('Удаление статьи')}</h4>
			                            </div>
			                            <div class="modal-body">
			                                ${_('Вы действительно хотите удалить статью')} <strong>"${a.getvalue("mainname", lang)}"</strong>?
			                            </div>
			                            <div class="modal-footer">
			                                <button type="button" class="btn btn-default" data-dismiss="modal">${_('Отмена')}</button>
			                                <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">${_('Удалить')}</a>
			                            </div>
		                                </div>
		                            </div>
		                        </div>  
		                        % if a.getvalue("previewtext", lang) is not None:
		                            <small>${a.getvalue("previewtext", lang)}</small>
		                        % else:
		                            ...
		                        % endif
		                    </div>
	                        </div>
	                        
	                    % endif
	                % endif
                    % endif

	        % if a.status == "ready":
                    
	            <div class="media">
	                ##<a class="pull-left" href="${request.route_url('article', url=a.url)}">
                        ##<img alt='' class="media-object img-rounded pull-left" src="${a.previewpict}" width="140"/>
	                ##</a>
	                <div class="media-body">
		            <h4 class="media-heading"><a href="${request.route_url('article', url=a.url)}">${a.getvalue("mainname", lang)}</a>
		                % if auth:
                                    % if a.user == authuser or user.admin == 1: 
                                        <small>
		                            <a class="btn btn-default btn-xs" href="${request.route_url('edit', pub='article', id=a.id)}">${_('Править')}</a>
		                            <a class="btn btn-default btn-xs" data-toggle="modal" data-target=".modal-remove${a.id}">${_('Удалить')}</a>
		                        </small></h4>
		            <div class="modal fade modal-remove${a.id}" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		                <div class="modal-dialog">
		                    <div class="modal-content">
			                <div class="modal-header">
			                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">${_('Закрыть')}</span></button>
			                    <h4 class="modal-title" id="modalRemoveLabel">${_('Удаление статьи')}</h4>
			                </div>
			                <div class="modal-body">
			                    ${_('Вы действительно хотите удалить статью')} <strong>"${a.getvalue("mainname", lang)}"</strong>?
			                </div>
			                <div class="modal-footer">
			                    <button type="button" class="btn btn-default" data-dismiss="modal">${_('Отмена')}</button>
			                    <a href="${request.route_url('remove', pub='article', id=a.id)}" type="button" class="btn btn-primary">${_('Удалить')}</a>
			                </div>
		                    </div>
		                </div>
		            </div>

                                    % endif
		                    % if a.getvalue("previewtext", lang) is not None:
		                        <small>${a.getvalue("previewtext", lang)}</small>
		                    % else:
		                        ...
		                    % endif
	                </div>
	            </div>
	                        % endif
                % endif
                % endif
	    % endfor  
      % else:
	    ${_('Ничего нет...')}
      % endif  	
    </div>
</div>
</div>



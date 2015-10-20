## -*- coding: utf-8 -*-

<%inherit file="lietlahti:templates/template_base.mak"/>

<div class="inner">
    <div class="row">
        <div class="social-likes pull-letf">
            <div class="facebook" title="Share link on Facebook" data-title="${_('Лиетлахти, природно-этнографический парк')}">&nbsp</div>
            <div class="twitter" title="Share link on Twitter" data-title="${_('Лиетлахти, природно-этнографический парк')}">&nbsp</div>
            <div class="plusone" title="Share link on Google+" data-title="${_('Лиетлахти, природно-этнографический парк')}">&nbsp</div>
            <div class="pinterest" title="Share image on Pinterest" data-media="${_('Лиетлахти, природно-этнографический парк')}" data-title="">&nbsp</div>
        </div>
        <div class="col-md-8 col-md-offset-2 col-sm-8 col-sm-offset-2" align='justify'>
	    % if article:
	        <p>
	            % if auth:
	                <a class="btn btn-default" href="${request.route_url('edit', pub='article', id=article.id)}">${_('Править')}</a>
	                <a class="btn btn-default" data-toggle="modal" data-target=".modal-remove">${_('Удалить')}</a>
	                <div class="modal fade modal-remove" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		            <div class="modal-dialog">
		                <div class="modal-content">
		                    <div class="modal-header">
		                        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">${_('Закрыть')}</span></button>
		                        <h4 class="modal-title" id="modalRemoveLabel">${_('Удаление статьи')}</h4>
		                    </div>
		                    <div class="modal-body">
		                        ${_('Вы действительно хотите удалить статью')} <strong>"${article.getvalue("mainname", lang)}"</strong>?
                                        ..
		                    </div>
		                    <div class="modal-footer">
		                        <button type="button" class="btn btn-default" data-dismiss="modal">${_('Отмена')}</button>
		                        <a href="${request.route_url('remove', pub='article', id=article.id)}" type="button" class="btn btn-primary">${_('Удалить')}</a>
		                    </div>
		                </div>
		            </div>
	                </div>  
	            % endif 
	        </p>
                % if article.getvalue("maintext", lang) is not None:
                    ${article.getvalue("maintext", lang)|n}
                % else:
                    ${_('Ничего нет')} :(
                % endif
	    % else:
	        ${_('Такой публикации нет')}
	    % endif  	
	    
	    % if comments is not None and len(comments.all()) > 0:
	        <hr class="style-thin">
	        <div class="push1"></div>
                
	        % for p in comments:
	            <div class="row">
	                <div class="panel panel-default">
		            <div class="panel-heading">
     		                <h4>${p.name}: <small>${p.date.strftime('%d/%m/%Y %H:%M')}</small>
		                    % if auth:
		                        % if p.name == authuser:
		                            <a data-toggle="modal" data-target="#editModal${p.id}"><span class="glyphicon glyphicon-pencil"></span></a>
		                            <div class="modal fade" id="editModal${p.id}" tabindex="-1" role="dialog" aria-labelledby="editModalLabel${p.id}" aria-hidden="true">
  		                                <div class="modal-dialog">
    		                                    <div class="modal-content">
      		                                        <div class="modal-header">
        	                                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        	                                            <h4 class="modal-title" id="editModalLabel${p.id}">${_('Правка записи')}</h4>
      		                                        </div>
      		                                        <div class="modal-body">
        	                                            <form role="form" method="post" action="${request.route_url('edit', pub='post', id=p.id)}">
		                                                <textarea class="form-control" id="newpost" name="newpost" rows="4">${p.post|n}</textarea>
		                                                <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
      		                                        </div>
      		                                        <div class="modal-footer">
        	                                            <button type="button" class="btn btn-default" data-dismiss="modal">${_('Закрыть')}</button>
        	                                            <button type="submit" class="btn btn-primary">${_('Сохранить')}</button>
		                                            </form>
		                                        </div>
		                                    </div>
		                                </div>
		                            </div>
		                        % endif
		                        <a data-toggle="modal" data-target=".bs-delete-modal-sm${p.id}"><span class="glyphicon glyphicon-trash"></span></a>
		                        <div class="modal fade bs-delete-modal-sm${p.id}" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
		                            <div class="modal-dialog">
		                                <div class="modal-content">
		                                    <div class="modal-header">
		                                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		                                        <h4 class="modal-title" id="deleteModalLabel${p.id}">${_('Удаление записи')}</h4>
		                                    </div>
		                                    <div class="modal-body">
      		                                        <a href="${request.route_url('remove', pub='post', id=p.id)}">${_('Да, удалите немедленно')}!</a>
		                                    </div>
		                                    <div class="modal-footer">
		                                        <button type="button" class="btn btn-default" data-dismiss="modal">${_('Отменить')}</button>
		                                    </div>
		                                </div>
		                            </div>
		                        </div>
		                    % endif
		                </h4>
		            </div>
		            <div class="panel-body">
		                ${p.post|n}
		            </div>
	                </div>
	            </div>
	        % endfor
	    % endif
	    
	    <hr class="style-thin">
	    <div class="push1"></div>
	    
	    <div class="row">
	        <form role="form" method="post" action="${req.route_url('newpost')}">
	            ##<div class="form-group">
     	            ##<div class="col-md-9 col-md-offset-2 col-sm-9 col-sm-offset-2">
	            % if not auth:
	                <input type="text" class="form-control" id="username" name="username" placeholder="${_("Представьтесь пожалуйста")}">
	            % endif
                    
     	            <textarea class="form-control" id="userpost" name="userpost" placeholder="${_("Оставьте комментарий...")}" rows=2></textarea>
	            <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
	            <input type="hidden" id="ppage" name="ppage" value="${article.url}" />
	            <input type="hidden" id="aid" name="aid" value="${article.id}" />
                    
	            % if not auth:
	                <div class="g-recaptcha" data-sitekey="${captchakey}" data-theme="dark"></div>
	            % endif
                    
	            <button style="margin: 10px 0; margin-left: 2px;" type="submit" class="btn btn-default pull-right" id="submit" name="submit" title=${_("Послать")} tabindex="3">Послать</button>
     	            ##</div>
	            ##</div>
            </div>		
        </div>
    </div>     
    
    
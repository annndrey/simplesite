## -*- coding: utf-8 -*-

<%inherit file="lietlahti:templates/template_base.mak"/>

  <div class="inner">
    <div class="row">
      <div class="col-md-8 col-md-offset-2 col-sm-8 col-sm-offset-2" align='justify'>
	% if article:
	  <p>
	    % if auth:
	      <a class="btn btn-default" href="${request.route_url('edit', pub='article', id=article.id)}">Править</a>
	      <a class="btn btn-default" data-toggle="modal" data-target=".modal-remove">Удалить</a>
	      <div class="modal fade modal-remove" tabindex="-1" role="dialog" aria-labelledby="modalRemoveLabel" aria-hidden="true">
		<div class="modal-dialog">
		  <div class="modal-content">
		    <div class="modal-header">
		      <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
		      <h4 class="modal-title" id="modalRemoveLabel">Удаление статьи</h4>
		    </div>
		    <div class="modal-body">
		      Вы действительно хотите удалить статью <strong>"${article.mainname}"</strong>?
		    </div>
		    <div class="modal-footer">
		      <button type="button" class="btn btn-default" data-dismiss="modal">Отмена</button>
		      <a href="${request.route_url('remove', pub='article', id=article.id)}" type="button" class="btn btn-primary">Удалить</a>
		    </div>
		  </div>
		</div>
	      </div>  
	      % endif 
	  </p>
${article.maintext|n}
	% else:
	  There's no such article
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
        	    <h4 class="modal-title" id="editModalLabel${p.id}">Правка записи</h4>
      		    </div>
      		    <div class="modal-body">
        	    <form role="form" method="post" action="${request.route_url('edit', pub='post', id=p.id)}">
		    <textarea class="form-control" id="newpost" name="newpost" rows="4">${p.post|n}</textarea>
		    <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
      		    </div>
      		    <div class="modal-footer">
        	    <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
        	    <button type="submit" class="btn btn-primary">Сохранить</button>
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
		    <h4 class="modal-title" id="deleteModalLabel${p.id}">Удаление записи</h4>
		    </div>
		    <div class="modal-body">
      		    <a href="${request.route_url('remove', pub='post', id=p.id)}">Да, удалите немедленно!</a>
		    </div>
		    <div class="modal-footer">
		    <button type="button" class="btn btn-default" data-dismiss="modal">Отменить</button>
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
	  <input type="text" class="form-control" id="username" name="username" placeholder="Представьтесь пожалуйста">
	  % endif

     	  <textarea class="form-control" id="userpost" name="userpost" placeholder="Оставьте комментарий..." rows=2></textarea>
	  <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
	  <input type="hidden" id="ppage" name="ppage" value="${article.url}" />
	  <input type="hidden" id="aid" name="aid" value="${article.id}" />

	  % if not auth:
	  <div class="g-recaptcha" data-sitekey="${captchakey}" data-theme="dark"></div>
	  % endif

	  <button style="margin: 10px 0; margin-left: 2px;" type="submit" class="btn btn-default pull-right" id="submit" name="submit" title="Послать" tabindex="3">Послать</button>
     	  ##</div>
	  ##</div>
      </div>		
    </div>
  </div>     
    

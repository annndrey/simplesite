## -*- coding: utf-8 -*-
<%inherit file="lietlahti:templates/template_base.mak"/>

<div class="container">
    <div class="inner">
        <div class="col-md-6 col-md-offset-3 col-sm-6 col-sm-offset-3" align='justify'>
	    <form class="form-signin" role="form" method="post" action="${req.route_url('login')}">
	        % for msg in req.session.pop_flash():
	            <div class="alert alert-${msg['class'] if 'class' in msg else 'success'} alert-dismissable" role="alert">
	                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
	                ${msg['text']}
	            </div>
	        % endfor
	        <input type="hidden" id="csrf" name="csrf" value="${req.session.get_csrf_token()}" />
	        <input type="text" class="form-control" placeholder="${_('имя')}" required="required" autofocus="autofocus" id="user" name="user" title="${_("Введите имя пользователя")}" value="" maxlength="254" tabindex="1" autocomplete="off" />
	        <input type="password" class="form-control" placeholder="${_('пароль')}" required="required" id="pass" name="pass" title="${_("Введите пароль")}" value="" maxlength="254" tabindex="2" autocomplete="off" />
	        <button type="submit" class="btn btn-lg btn-primary btn-block" id="submit" name="submit" title="${_("Войти")}" tabindex="3">${_('Войти')}</button>
	    </form>	
        </div>
    </div>
</div>
##</div>

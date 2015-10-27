## -*- coding: utf-8 -*-
<%inherit file="lietlahti:templates/template_base.mak"/>

<script type="text/javascript">
 $(document).ready(function(){
     $("#registersocial").popover({
         placement : 'bottom',
         html : 'true'
     });
});

</script>


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
                <a href="#" id='registersocial' class="btn btn-default" data-toggle="popover" title="${_('Войти через...')}" data-html="true" data-content='
                   % for lp in login_providers.keys():
                   % if lp == 'twitter': 
                   <span><a data-toggle="modal" href="#modalTwitterEmail"><img src="${req.static_url('lietlahti:static/icons/loginproviders/%s.png' % lp)}" title="${lp.capitalize()}">${lp}</a></span>
                   % else:
                   <span><a href="${req.route_url('oauthwrapper')}?prov=${lp.lower()}"><img src="${req.static_url('lietlahti:static/icons/loginproviders/%s.png' % lp)}" title="${lp.capitalize()}">${lp}</a><span>
                   % endif 
                   % endfor
                   '>${_('Войти через...')}</a>
                <a data-toggle="modal" href="#modalPassRestore" class="btn btn-default">${_('Восстановить пароль')}</a>
	    </form>	
        </div>
    </div>
</div>

<div class="modal fade" id="modalTwitterEmail" tabindex="-1" role="dialog" aria-labelledby="modalLabelTwitter" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">${_('Закрыть')}</span></button>
        <h4 class="modal-title" id="modalLabelTwitter">${_('Введите email')}</h4>
      </div>
      <div class="modal-body">
        <form method="GET" action="${req.route_url('oauthwrapper')}" class="form-inline" role="form" id="emailForm">
          <div class="form-group">
            <label for="twitterEmail">${_('Email')}</label>
            <input type="email" class="form-control" name="twitterEmail" id="twitterEmail" placeholder="${_('Введите email')}">
            <input type="hidden" name="prov" id="prov" value="twitter">
            <input type="hidden" name="csrf" value="${req.session.get_csrf_token()}" />
          </div>
      </div>
      <div class="modal-footer">
        <input type="submit" value="${_("Войти")}" class="btn btn-primary"/>
        </form>
        <button type="button" class="btn btn-default" data-dismiss="modal">${_('Закрыть')}</button>
      </div>
    </div>
  </div>
</div>

##</div>

<div class="modal fade" id="modalPassRestore" tabindex="-1" role="dialog" aria-labelledby="modalLabelPassRestore" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">${_('Закрыть')}</span></button>
        <h4 class="modal-title" id="modalLabelTwitter">${_('Введите имя пользователя или email')}</h4>
      </div>
      <div class="modal-body">
        <form method="GET" action="${req.route_url('passrestore')}" class="form-inline" role="form" id="usernameForm">
          <div class="form-group">
            <input type="text" class="form-control" name="userName" id="userName" placeholder="${_('имя пользователя/email')}">
            <input type="hidden" name="csrf" value="${req.session.get_csrf_token()}" />
          </div>
      </div>
      <div class="modal-footer">
        <input type="submit" value="${_("Восстановить")}" class="btn btn-primary"/>
        </form>
        <button type="button" class="btn btn-default" data-dismiss="modal">${_('Закрыть')}</button>
      </div>
    </div>
  </div>
</div>

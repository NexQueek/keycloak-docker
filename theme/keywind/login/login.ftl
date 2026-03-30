<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>

    <#if section = "header">
        ${msg("loginTitle",(realm.displayName!''))}

    <#elseif section = "form">
    <div class="flex flex-col items-stretch p-6 md:p-8 lg:p-16">

        {{-- Logo / Header --}}
        <div class="flex items-center justify-between">
            <a href="${properties.kcLogoLink!'#'}">
                <#if properties.kcLogoUrl??>
                    <img src="${properties.kcLogoUrl}" alt="${realm.displayName!''}" class="h-8" />
                <#else>
                    <span class="text-xl font-bold">${realm.displayName!''}</span>
                </#if>
            </a>
        </div>

        <h3 class="mt-8 text-center text-xl font-semibold md:mt-12 lg:mt-24">
            ${msg("loginTitle", (realm.displayName!''))}
        </h3>
        <p class="text-base-content/70 mt-2 text-center text-sm">
            ${msg("loginTitleHtml", (realm.displayNameHtml!''))?no_esc}
        </p>

        {{-- Global error messages --}}
        <#if messagesPerField.existsError('username','password')>
            <div class="alert alert-error mt-4 text-sm">
                <span class="iconify lucide--circle-alert size-4"></span>
                <span>${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
            </div>
        </#if>

        <div class="mt-6 md:mt-10">
            <form id="kc-form-login" action="${url.loginAction}" method="post">

                {{-- Email / Username --}}
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">
                        <#if !realm.loginWithEmailAllowed>
                            ${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>
                            ${msg("usernameOrEmail")}
                        <#else>
                            ${msg("email")}
                        </#if>
                    </legend>
                    <label class="input w-full focus:outline-0 <#if messagesPerField.existsError('username')>input-error</#if>">
                        <span class="iconify lucide--mail text-base-content/80 size-5"></span>
                        <input
                            class="grow focus:outline-0"
                            id="username"
                            name="username"
                            type="<#if realm.loginWithEmailAllowed && realm.registrationEmailAsUsername>email<#else>text</#if>"
                            placeholder="<#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>"
                            value="${(login.username!'')?html}"
                            autocomplete="<#if realm.loginWithEmailAllowed>email<#else>username</#if>"
                            <#if usernameHidden??>style="display:none"</#if>
                        />
                    </label>
                </fieldset>

                {{-- Password --}}
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">${msg("password")}</legend>
                    <label class="input w-full focus:outline-0 <#if messagesPerField.existsError('password')>input-error</#if>">
                        <span class="iconify lucide--key-round text-base-content/80 size-5"></span>
                        <input
                            class="grow focus:outline-0"
                            id="password"
                            name="password"
                            type="password"
                            placeholder="${msg("password")}"
                            autocomplete="current-password"
                        />
                        <button
                            type="button"
                            aria-label="${msg("showPassword")}"
                            class="btn btn-xs btn-ghost btn-circle"
                            onclick="
                                var p = document.getElementById('password');
                                var eyeOn = document.getElementById('eye-on');
                                var eyeOff = document.getElementById('eye-off');
                                if (p.type === 'password') {
                                    p.type = 'text';
                                    eyeOn.style.display = 'none';
                                    eyeOff.style.display = 'inline';
                                } else {
                                    p.type = 'password';
                                    eyeOn.style.display = 'inline';
                                    eyeOff.style.display = 'none';
                                }
                            ">
                            <span id="eye-on" class="iconify lucide--eye size-4"></span>
                            <span id="eye-off" class="iconify lucide--eye-off size-4" style="display:none"></span>
                        </button>
                    </label>
                </fieldset>

                {{-- Forgot Password --}}
                <#if realm.resetPasswordAllowed>
                    <div class="text-end">
                        <a class="label-text text-base-content/80 text-xs" href="${url.loginResetCredentialsUrl}">
                            ${msg("doForgotPassword")}
                        </a>
                    </div>
                </#if>

                {{-- Remember Me --}}
                <#if realm.rememberMe && !usernameHidden??>
                    <div class="mt-4 flex items-center gap-3 md:mt-6">
                        <input
                            class="checkbox checkbox-sm checkbox-primary"
                            id="rememberMe"
                            name="rememberMe"
                            type="checkbox"
                            <#if login.rememberMe??>checked</#if>
                        />
                        <label class="text-sm" for="rememberMe">${msg("rememberMe")}</label>
                    </div>
                </#if>

                {{-- Hidden fields --}}
                <input type="hidden" id="id-hidden-input" name="credentialId"
                    <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if> />

                {{-- Submit --}}
                <button
                    class="btn btn-primary btn-wide mt-4 max-w-full gap-3 md:mt-6"
                    id="kc-login"
                    name="login"
                    type="submit">
                    <span class="iconify lucide--log-in size-4"></span>
                    ${msg("doLogIn")}
                </button>
            </form>

            {{-- Social Login (Google etc.) --}}
            <#if realm.password && social?? && social.providers?has_content>
                <#list social.providers as p>
                    <a
                        class="btn btn-ghost btn-wide border-base-300 mt-4 max-w-full gap-3"
                        href="${p.loginUrl}"
                        id="social-${p.alias}">
                        <#if p.iconClasses?has_content>
                            <i class="${p.iconClasses!''}" aria-hidden="true"></i>
                        <#else>
                            <img
                                alt="${p.displayName!''}"
                                class="size-6"
                                src="${url.resourcesPath}/img/${p.alias}-mini.svg"
                                onerror="this.style.display='none'"
                            />
                        </#if>
                        ${msg("loginSocialTitle", p.displayName!'')}
                    </a>
                </#list>
            </#if>

            {{-- Register link --}}
            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                <p class="text-base-content/80 mt-4 text-center text-sm md:mt-6">
                    ${msg("noAccount")}
                    <a class="text-primary ms-1 hover:underline" href="${url.registrationUrl}">
                        ${msg("doRegister")}
                    </a>
                </p>
            </#if>
        </div>
    </div>
    </#if>

</@layout.registrationLayout>

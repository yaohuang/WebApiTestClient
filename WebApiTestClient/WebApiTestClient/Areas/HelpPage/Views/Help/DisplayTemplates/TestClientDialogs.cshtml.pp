@using System.Web.Http
@using $rootnamespace$.Areas.HelpPage.Models
@model HelpPageApiModel

@{
  var description = Model.ApiDescription;
  string applicationPath = Request.ApplicationPath;
  if (!applicationPath.EndsWith("/"))
  {
    applicationPath += "/";
  }
}

<button id="testClientButton">Test API</button>
<div id="testClientDialog" title="@description.HttpMethod @description.RelativePath">
  <input class="httpMethod" spellcheck="false" data-bind="value: HttpMethod" />
  <input class="uriPath" spellcheck="false" data-bind="value: UriPath" />
  <div data-bind="visible: UriParameters.length > 0">
    <h5 class="ui-widget-header">URI parameters</h5>
    <div class="panel">
      <div data-bind="foreach: UriParameters">
        <div>
          <input readonly="true" spellcheck="false" tabindex="100" class="uriParameterLabel" data-bind="value: '{' + name + '}'" />
          <span>= </span>
          <input spellcheck="false" data-bind="value: value, valueUpdate: 'afterkeydown', enable: enabled" />
          <input type="checkbox" data-bind="checked: enabled" />
        </div>
      </div>
    </div>
  </div>
  <h5 class="ui-widget-header">Headers | <a style="text-decoration: underline" href="#" data-bind="click: addHeader">Add header</a>
  </h5>
  <div class="panel">
    <div data-bind="foreach: RequestHeaders">
      <div>
        <input spellcheck="false" data-bind='value: name, uniqueName: true' />
        <span>: </span>
        <input spellcheck="false" data-bind='value: value, uniqueName: true' />
        <a href='#' data-bind='click: $root.removeHeader'>Delete</a>
      </div>
    </div>
  </div>
  <h5 class="ui-widget-header">
    <input type='checkbox' data-bind='checked: ShouldShowBody' />Body</h5>
  <div data-bind="visible: ShouldShowBody">
    <div data-bind="visible: SampleTypes.length > 0">
      <span>Samples: </span>
      <select data-bind="options: SampleTypes, value: RequestMediaType"></select>
    </div>
    <pre><textarea class="sampleArea" spellcheck="false" data-bind="value: RequestBody, valueUpdate: 'afterkeydown'" rows="7"></textarea></pre>
  </div>
</div>

<div id="testClientResponseDialog" title="Response for @description.HttpMethod @description.RelativePath" data-bind="with: response">
  <div class="responseStatusDiv">
    <h5 class="ui-widget-header">Status</h5>
    <span data-bind="text: status"></span>
  </div>
  <div class="responseHeaderDiv">
    <h5 class="ui-widget-header">Headers</h5>
    <textarea spellcheck="false" data-bind="value: headers" class="sampleArea" readonly='readonly' rows="6"></textarea>
  </div>
  <div class="responseBodyDiv">
    <h5 class="ui-widget-header">Body</h5>
    <textarea spellcheck="false" data-bind="value: content" class="sampleArea" readonly='readonly' rows="10"></textarea>
  </div>
</div>

<script>
  testClientModel = {
    HttpMethod: '@Model.ApiDescription.HttpMethod',
    UriPathTemplate: @Html.Raw(Json.Encode(Model.ApiDescription.RelativePath)),
    UriParameters: [
            @foreach (var parameter in Model.ApiDescription.ParameterDescriptions)
            {
              if (parameter.Source == System.Web.Http.Description.ApiParameterSource.FromUri)
              {
                    @:{ name: "@parameter.Name", value: "" },
                }
            }
    ],
    Samples: {
      @Html.Raw(@String.Join(",", Model.SampleRequests.Select(s => String.Format("\"{0}\": \"{1}\"", s.Key, HttpUtility.UrlEncode(s.Value.ToString()))).ToArray()))
    },
    BaseAddress: '@applicationPath'
  };
</script>
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
    <table class="test-client">
        <tr>
            <td class="httpMethod">
                <input data-bind="value: HttpMethod" /></td>
            <td class="uriPath">
                <input data-bind="value: UriPath" /></td>
        </tr>
    </table>
    <div class="test-client" data-bind="visible: UriParameters.length > 0">
        <h5 class="ui-widget-header">URI parameters</h5>
        <div class="panels">
            <table>
                <tbody data-bind="foreach: UriParameters">
                    <tr>
                        <td><span data-bind="text: '{' + name + '}'"></span></td>
                        <td>=</td>
                        <td>
                            <input data-bind="value: value, valueUpdate: 'afterkeydown'" /></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <h5 class="ui-widget-header">Headers</h5>
    <div class="panels">
        <button data-bind="click: addHeader">Add Header</button>
        <table class="test-client">
            <tbody data-bind="foreach: RequestHeaders">
                <tr>
                    <td>
                        <input data-bind='value: name, uniqueName: true' /></td>
                    <td>:</td>
                    <td>
                        <input data-bind='value: value, uniqueName: true' /></td>
                    <td><a href='#' data-bind='click: $root.removeHeader'>Delete</a></td>
                </tr>
            </tbody>
        </table>
    </div>
    <h5 class="ui-widget-header">
        <input type='checkbox' data-bind='checked: ShouldShowBody' />Body</h5>
    <div data-bind="visible: ShouldShowBody">
        <div data-bind="visible: SampleTypes.length > 0">
            Samples:
            <select data-bind="options: SampleTypes, value: RequestMediaType"></select>
        </div>
        <pre><textarea class="sampleArea" data-bind="value: RequestBody, valueUpdate: 'afterkeydown'" rows="7"></textarea></pre>
    </div>
</div>

<div id="testClientResponseDialog" title="Response for @description.HttpMethod @description.RelativePath" data-bind="with: response">
    <div class="responseStatusDiv">
        <h5 class="ui-widget-header">Status</h5>
        <span data-bind="text: status"></span>
    </div>
    <div class="responseHeaderDiv">
        <h5 class="ui-widget-header">Headers</h5>
        <textarea data-bind="value: headers" class="sampleArea" readonly='readonly' rows="6"></textarea>
    </div>
    <div class="responseBodyDiv">
        <h5 class="ui-widget-header">Body</h5>
        <textarea data-bind="value: content" class="sampleArea" readonly='readonly' rows="10"></textarea>
    </div>
</div>

<script>
    testClientModel = {
        HttpMethod: '@Model.ApiDescription.HttpMethod',
        UriPathTemplate: '@Html.Raw(Model.ApiDescription.RelativePath)',
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
            @foreach (var sample in Model.SampleRequests)
            {
                @:"@sample.Key": "@Html.Raw(HttpUtility.UrlEncode(sample.Value.ToString()))",
            }
        },
        BaseAddress: '@applicationPath'
    };
</script>
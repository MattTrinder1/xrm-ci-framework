﻿using System;
using System.Management.Automation;
using Microsoft.Crm.Sdk.Messages;
using Microsoft.Xrm.Sdk;

namespace Xrm.Framework.CI.PowerShell.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Publishes a Dynamics Theme</para>
    /// <para type="description">The Publish-XrmTheme cmdlet publishes a Dynamics Theme.
    /// </summary>
    /// <example>
    ///   <code>C:\PS>Publish-XrmTheme -ThemeId $themeId</code>
    ///   <para>Publishes a theme.</para>
    /// </example>
    /// <para type="link" uri="https://docs.microsoft.com/en-us/dotnet/api/microsoft.crm.sdk.messages.publishthemerequest?view=dynamics-general-ce-9">PublishTheme.</para>
    [Cmdlet(VerbsData.Publish, "XrmTheme")]
    public class PublishXrmThemeCommand : XrmCommandBase
    {
        #region Parameters

        /// <summary>
        /// <para type="description">The Id of the Theme to publish.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public Guid ThemeId { get; set; }

        #endregion

        #region Process Record

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            base.WriteVerbose(string.Format("Publishing Theme"));

            var req = new PublishThemeRequest();
            req.Target = new EntityReference("theme", ThemeId);

            OrganizationService.Execute(req);

            base.WriteVerbose(string.Format("Theme Published"));
        }

        #endregion
    }
}
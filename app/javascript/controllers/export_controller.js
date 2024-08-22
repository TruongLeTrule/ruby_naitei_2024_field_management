import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['status']

  connect() {}

  export(event) {
    event.preventDefault();

    const currentParams = window.location.search;
    const currentUrl = window.location.origin + window.location.pathname + '/export' + currentParams;

    fetch(currentUrl, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => {
      if (data.jid) {
        const jobId = data.jid;
        const intervalName = `job_${jobId}`;
        this.statusTarget.textContent = I18n.t('export.begin');

        window[intervalName] = setInterval(() => {
          this.getExportJobStatus(jobId, intervalName);
        }, 800);
      }
    })
    .catch(error => console.error(error));
  }

  getExportJobStatus(jobId, intervalName) {
    const exportStatusUrl = `${window.location.origin}${window.location.pathname}/export_status?job_id=${jobId}`;
    fetch(exportStatusUrl, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => {
      if (data) {
        const percentage = data.percentage;
        this.statusTarget.textContent = I18n.t('export.percent', {percent: percentage});

        if (data.status === 'complete') {
          this.statusTarget.textContent = I18n.t('export.download');
          setTimeout(() => {
            clearInterval(window[intervalName]);
            delete window[intervalName];
            const downloadUrl = `${window.location.origin}${window.location.pathname}/export_download.xlsx?job_id=${jobId}`;
            window.location.href = downloadUrl;
            this.statusTarget.textContent = '';
          }, 500);
        }
      }
    })
    .catch(error => console.error(error));
  }
}

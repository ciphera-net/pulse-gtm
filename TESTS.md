# Test scenarios

`___TESTS___` in `template.tpl` is `scenarios: []`, and deliberately so: both
templates in the gallery that this one was modelled on ship it empty, and the
section is meant to be authored *in the GTM Template Editor*, which serialises
it. Hand-written YAML there is a large, unverifiable surface for a parser that
reports only "The template.tpl file is invalid".

The scenarios below are what the tag should be tested against. Paste them into
the editor's Tests tab, run them there, and let the editor write the section.

```yaml
scenarios:
- name: Injects the core script and nothing else by default
  code: |-
    const mockData = { domain: 'example.com' };

    mock('injectScript', (url, onSuccess) => {
      assertThat(url).isEqualTo('https://js.ciphera.net/script.js');
      onSuccess();
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
- name: Sets the domain on window.pulseConfig, because attributes are not available
  code: |-
    const mockData = { domain: 'example.com' };
    let written;

    mock('copyFromWindow', () => undefined);
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.domain).isEqualTo('example.com');
- name: Leaves the domain unset when blank, so the tracker auto-detects the hostname
  code: |-
    const mockData = {};
    let written;

    mock('copyFromWindow', () => undefined);
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.domain).isEqualTo(undefined);
- name: Keeps a pulseConfig the site already set
  code: |-
    const mockData = { domain: 'example.com' };
    let written;

    mock('copyFromWindow', () => ({ hashMode: true }));
    mock('setInWindow', (key, value) => { if (key === 'pulseConfig') written = value; });
    mock('injectScript', (url, onSuccess) => onSuccess());

    runCode(mockData);

    assertThat(written.hashMode).isEqualTo(true);
    assertThat(written.domain).isEqualTo('example.com');
- name: Loads the companion second when asked, and only then
  code: |-
    const mockData = { domain: 'example.com', companion: true };
    const loaded = [];

    mock('injectScript', (url, onSuccess) => { loaded.push(url); onSuccess(); });

    runCode(mockData);

    assertThat(loaded).isEqualTo([
      'https://js.ciphera.net/script.js',
      'https://js.ciphera.net/script.interactions.js'
    ]);
- name: Fails the tag when the script cannot load, rather than reporting success
  code: |-
    const mockData = { domain: 'example.com' };

    mock('injectScript', (url, onSuccess, onFailure) => onFailure());

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
```

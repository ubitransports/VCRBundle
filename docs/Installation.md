In your MS where you want to install it, add in `composer.json` :
```json
"repositories": [
    {
        "type": "vcs",
        "url": "git@github.com:ubitransports/VCRBundle.git"
    }
]
```
And require the bundle with composer `--dev ubitransport/vcr-bundle`


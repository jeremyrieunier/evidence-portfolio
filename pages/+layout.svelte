<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;
</script>

<EvidenceDefaultLayout {data} title="Jeremy Rieunier" githubRepo="https://github.com/jeremyrieunier/" xProfile="https://x.com/jeremyrieunier">
	<slot slot="content" />
</EvidenceDefaultLayout>
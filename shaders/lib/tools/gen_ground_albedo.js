import fs from 'fs'

import { albedos, defaults } from './datasets/ground_albedos_XYZ.js'
import { eToNumber } from './lib/toStringParseable.js'


const finalVars = [
	'variable.float.skyAlbedo_X=smooth(if(',
	'variable.float.skyAlbedo_Y=smooth(if(',
	'variable.float.skyAlbedo_Z=smooth(if(',
]

for (const [name, biome] of Object.entries(albedos)) {
	for (const [channelId, channel] of biome.entries()) {
		const num = eToNumber(channel)
		const str = num.includes('.') ? num : num + '.0'
		finalVars[channelId] += `biome_category == ${name}, ${str}, `
	}
}

for (const channel of finalVars.keys()) {
	finalVars[channel] += `${defaults[channel]}), 10.0, 10.0)`
}


const targetFilePath = '../../shaders.properties'
const regex = [
	/^variable\.float\.skyAlbedo_X\=/,
	/^variable\.float\.skyAlbedo_Y\=/,
	/^variable\.float\.skyAlbedo_Z\=/,
]

const fileContent = fs.readFileSync(targetFilePath, 'utf8')
const lines = fileContent.split('\n')

for (let i = 0; i < lines.length; i++) {
	for (let j = 0; j < regex.length; j++) {
		if (regex[j].test(lines[i])) {
			lines[i] = finalVars[j]
		}
	}
}

fs.writeFileSync(targetFilePath, lines.join('\n'))
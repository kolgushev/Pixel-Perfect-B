import fs from 'fs'

import {datasetsXYZ, datasetsXYZRad} from './sky_gen_coeffs_XYZ.js'
const datasets = datasetsXYZ
const datasetsRad = datasetsXYZRad


const elevationFn = 'elevation'
const turbidityFn = 'turbidity'
const albedoFn = [
	'skyAlbedo_X',
	'skyAlbedo_Y',
	'skyAlbedo_Z',
]

const finalVars = []

const letterNames = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'H', 'Z']

for (const [channelId, channel] of datasets.entries()) {
	const channelLetter = ['X', 'Y', 'Z'][channelId]
	const letters = [

	]

	const stride = 9;
	for (let i = 0; i < stride; i++) {
		const letter = []

		for (let j = 0; j < channel.length; j += stride) {
			letter.push(channel[i + j])
		}

		letters.push(letter)
	}

	letters.push(datasetsRad[channelId])

	letters.map(letter => letter.map(number => Math.floor(number) === number ? number.toFixed(1) : number.toString()))

	for (const [letterId, letter] of letters.entries()) {
		const letterName = letterNames[letterId]
		const splines = []

		for (let i = 0; i < letter.length; i+= 6) {
			splines.push(`pow(1.0 - ${elevationFn}, 5.0) * ${letter[i + 0]} + 5.0 *  pow(1.0 - ${elevationFn}, 4.0) * pow(${elevationFn}, 1.0) * ${letter[i + 1]} + 10.0 * pow(1.0 - ${elevationFn}, 3.0) * pow(${elevationFn}, 2.0) * ${letter[i + 2]} + 10.0 * pow(1.0 - ${elevationFn}, 2.0) * pow(${elevationFn}, 3.0) * ${letter[i + 3]} + 5.0 * pow(1.0 - ${elevationFn}, 1.0) * pow(${elevationFn}, 4.0) * ${letter[i + 4]} + pow(${elevationFn}, 5.0) * ${letter[i + 5]}`)
		}

		const turbidities = []

		const stride = 10;
		for (let i = 0; i < splines.length; i += stride) {
			let str = 'if('
			
			// turbidity of 1-10 gets translated into 0-9
			for(let j = 0; j < stride - 1; j++) {
				// Iris doesn't like lerps
				// str += `between(${turbidityFn}, ${j}, ${j + 1}), lerp((${turbidityFn} - ${j}), ${splines[i + j]}, ${splines[i + j + 1]}), `;
				
				str += `between((${turbidityFn}), ${j}.0, ${j + 1}.0), ((${splines[i + j]}) * (${1 + j}.0 - (${turbidityFn})) + (${splines[i + j + 1]}) * ((${turbidityFn}) - ${j}.0)), `;
			}

			turbidities.push(`${str}(${splines[splines.length - 1]}))`)
		}

		// finalVars.push(`variable.float.${channelLetter}_${letterName}=lerp(${albedoFn}.${channelLetter.toLowerCase()}, ${turbidities[0]}, ${turbidities[1]})`)

		const varChannel = `${albedoFn[channelId]}`
		finalVars.push(`variable.float.${channelLetter}_${letterName}=((${turbidities[0]}) * (1 - (${varChannel})) + (${turbidities[1]}) * (${varChannel}))`)
		// finalVars.push(`variable.float.${channelLetter}_${letterName}=((${splines[0]}) * (1 - ${varChannel}) + (${splines[10]}) * (${varChannel}))`)
		// finalVars.push(`variable.float.${channelLetter}_${letterName}=${splines[0]}`)
	}
}

for(const letter of letterNames) {
	finalVars.push(`uniform.vec3.sky${letter}=vec3(X_${letter}, Y_${letter}, Z_${letter})`)
}

fs.writeFileSync('./generated/hw_sky.properties', finalVars.join('\n'))
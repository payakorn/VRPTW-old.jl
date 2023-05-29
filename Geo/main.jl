
groj = values=JSON.parsefile("Geo/th.json")

# d=VegaDatasets.VegaJSONDataset(countries50m, groj)
@vlplot(
    :geoshape,
    width=500, height=300,
    data={
        values=groj,
        format={
            type=:topojson,
            feature=:THAADM0gbOpen
        }
    },
)
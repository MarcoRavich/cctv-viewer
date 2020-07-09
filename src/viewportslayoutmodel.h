#ifndef VIEWPORTSLAYOUTMODEL_H
#define VIEWPORTSLAYOUTMODEL_H

#include <math.h>
#include <QtCore>
#include <QQmlEngine>

#define Q_PROPERTY_WRITE_IMPL(type, name, write, notify) \
    void write(const type &var) { \
        if (m_##name == var) \
            return; \
        m_##name = var; \
        emit notify(var); \
    }

// TODO: Reimplement this with QSize/QRect as a span property
class ViewportsLayoutItem : public QObject
{
    Q_OBJECT
    Q_ENUMS(Visible)

    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int rowSpan READ rowSpan WRITE setRowSpan NOTIFY rowSpanChanged)
    Q_PROPERTY(int columnSpan READ columnSpan WRITE setColumnSpan NOTIFY columnSpanChanged)
    Q_PROPERTY(ViewportsLayoutItem::Visible visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(QVariant volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
    explicit ViewportsLayoutItem(QObject *parent = nullptr);

    enum class Visible {
        Visible,
        Hidden
    };

    QString url() const { return m_url; }
    int rowSpan() const { return m_rowSpan; }
    int columnSpan() const { return m_columnSpan; }
    ViewportsLayoutItem::Visible visible() const { return m_visible; }
    QVariant volume() const { return m_volume; }

public slots:
    Q_PROPERTY_WRITE_IMPL(QString, url, setUrl, urlChanged)
    Q_PROPERTY_WRITE_IMPL(int, rowSpan, setRowSpan, rowSpanChanged)
    Q_PROPERTY_WRITE_IMPL(int, columnSpan, setColumnSpan, columnSpanChanged)
    Q_PROPERTY_WRITE_IMPL(ViewportsLayoutItem::Visible, visible, setVisible, visibleChanged)
    Q_PROPERTY_WRITE_IMPL(QVariant, volume, setVolume, volumeChanged)

signals:
    void changed();
    void urlChanged(const QString &url);
    void rowSpanChanged(int rowSpan);
    void columnSpanChanged(int columnSpan);
    void visibleChanged(ViewportsLayoutItem::Visible visible);
    void volumeChanged(const QVariant &volume);

private:
    QString m_url;
    int m_rowSpan;
    int m_columnSpan;
    ViewportsLayoutItem::Visible m_visible;
    QVariant m_volume;
};
QML_DECLARE_TYPE(ViewportsLayoutItem)

class ViewportsLayoutModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QSize size READ size WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(QSize aspectRatio READ aspectRatio WRITE setAspectRatio NOTIFY aspectRatioChanged)

public:
    explicit ViewportsLayoutModel(QObject *parent = nullptr);

    enum ModelRoles {
        UrlRole = Qt::UserRole + 1,
        ColumnSpanRole,
        RowSpanRole,
        VisibleRole,
        VolumeRole
    };

    // QAbstractItemModel interface
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
//    virtual bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
//    virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    // Model control interface
    Q_INVOKABLE QSize size() const { return QSize(m_columns, m_rows); }
    Q_INVOKABLE QSize aspectRatio() const { return m_aspectRatio; }
    Q_INVOKABLE ViewportsLayoutItem *get(int index) const { return m_items.value(index); }
    Q_INVOKABLE ViewportsLayoutItem *get(int column, int row) const { return get(dataIndex(column, row)); }
    Q_INVOKABLE ViewportsLayoutItem *set(int index, ViewportsLayoutItem *p);
    Q_INVOKABLE ViewportsLayoutItem *set(int column, int row, ViewportsLayoutItem *p) { return set(dataIndex(column, row), p); }
    Q_INVOKABLE void clear();
    Q_INVOKABLE void resize(int columns, int rows);
    Q_INVOKABLE void normalize();

    Q_INVOKABLE void fromJSValue(const QVariantMap &model);
    Q_INVOKABLE QVariantMap toJSValue() const;

public slots:
    void setSize(const QSize &size);
    void setAspectRatio(const QSize &ratio);

signals:
    void changed();
    void sizeChanged(const QSize &size);
    void aspectRatioChanged(const QSize &ratio);

protected:
    int dataIndex(int column, int row) const { return m_columns * row + column; }
    int column(int index) const { return index % m_columns; }
    int row(int index) const { return std::floor(index / m_columns); }

private:
    template<class T>
    const T& clamp(const T& v, const T& lo, const T& hi)
    {
        Q_ASSERT(!(hi < lo));
        return (v < lo) ? lo : (hi < v) ? hi : v;
    }

private:
    int m_columns;
    int m_rows;
    QSize m_aspectRatio;
    QVector<ViewportsLayoutItem *> m_items;
};
QML_DECLARE_TYPE(ViewportsLayoutModel)

#endif // VIEWPORTSLAYOUTMODEL_H